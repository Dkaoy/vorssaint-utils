// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import Combine

@MainActor
final class HostsService: ObservableObject {
    static let shared = HostsService()
    struct Pending: Codable {
        var before: [HostsProfile]
        var previous: [HostsProfile]?
        var resultHash: String
    }
    struct State: Codable {
        var profiles: [HostsProfile]
        var previous: [HostsProfile]?
        var pending: Pending?
    }
    struct Change: Identifiable {
        let id = UUID()
        let expected: Data
        let replacement: Data
        let profiles: [HostsProfile]
        let before: String
        let after: String
        let conflicts: [String]
    }
    @Published private(set) var profiles: [HostsProfile] = []
    @Published private(set) var busy = false
    @Published private(set) var canRestore = false
    @Published var error: String?
    @Published var notice: String?
    private var previous: [HostsProfile]?
    private var loaded = false
    private let target: URL
    private let storageOverride: URL?
    private var storage: URL? { storageOverride ?? PrivateFileStore.containerURL?.appendingPathComponent("Hosts", isDirectory: true) }
    // Injectable paths let previews and integration checks use private fixtures.
    init(target: URL = URL(fileURLWithPath: "/private/etc/hosts"), storage: URL? = nil) {
        self.target = target; self.storageOverride = storage
    }

    private func readHosts() throws -> Data {
        let values = try target.resourceValues(forKeys: [.isRegularFileKey, .isSymbolicLinkKey, .fileSizeKey])
        guard values.isRegularFile == true, values.isSymbolicLink != true else { throw HostsFailure.malformed }
        guard (values.fileSize ?? Int.max) <= HostsSupport.limit else { throw HostsFailure.tooLarge }
        return try Data(contentsOf: target)
    }
    private func document(_ data: Data) throws -> HostsSupport.Document {
        guard let text = String(data: data, encoding: .utf8), Data(text.utf8) == data else { throw HostsFailure.malformed }
        return try HostsSupport.parse(text)
    }
    /// Read-only disk snapshot; never load, reconcile or persist profile state.
    /// Damaged markers prevent writes, but must not prevent inspecting the file.
    func snapshot() throws -> HostsSupport.Snapshot {
        let data = try readHosts()
        guard let text = String(data: data, encoding: .utf8), Data(text.utf8) == data else {
            throw HostsFailure.malformed
        }
        return HostsSupport.Snapshot(text: text)
    }
    private func load() throws {
        guard !loaded, let storage else { if !loaded { throw HostsFailure.storage }; return }
        let file = storage.appendingPathComponent("profiles.json")
        if FileManager.default.fileExists(atPath: file.path) {
            let size = try file.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? Int.max
            guard size <= 2_000_000 else { throw HostsFailure.storage }
            var state = try JSONDecoder().decode(State.self, from: Data(contentsOf: file))
            try HostsSupport.validate(state.profiles)
            if let prior = state.previous { try HostsSupport.validate(prior) }
            if let pending = state.pending {
                try HostsSupport.validate(pending.before)
                if let prior = pending.previous { try HostsSupport.validate(prior) }
                // Recover a transaction interrupted while a system prompt was up.
                let disk = try readHosts()
                let wanted = Dictionary(uniqueKeysWithValues: state.profiles.filter(\.isEnabled).map { ($0.id, HostsSupport.body($0)) })
                let actual = try document(disk)
                if HostsSupport.digest(disk) != pending.resultHash && actual.blocks != wanted {
                    state.profiles = pending.before; state.previous = pending.previous
                }
                try persist(state.profiles, previous: state.previous)
            }
            try HostsSupport.validate(state.profiles)
            if let prior = state.previous { try HostsSupport.validate(prior) }
            profiles = state.profiles; previous = state.previous
        }
        canRestore = previous != nil; loaded = true
    }
    private func persist(_ profiles: [HostsProfile], previous: [HostsProfile]?, pending: Pending? = nil) throws {
        guard let storage, PrivateFileStore.createDirectory(at: storage),
              PrivateFileStore.write(try JSONEncoder().encode(State(profiles: profiles, previous: previous, pending: pending)),
                                     to: storage.appendingPathComponent("profiles.json")) else { throw HostsFailure.storage }
    }
    private func reconcile(_ doc: HostsSupport.Document) throws {
        guard Set(doc.blocks.keys).isSubset(of: Set(profiles.map(\.id))) else { throw HostsFailure.unknown }
        for index in profiles.indices {
            if let block = doc.blocks[profiles[index].id], block != HostsSupport.body(profiles[index]) {
                throw HostsFailure.malformed
            }
            profiles[index].isEnabled = doc.blocks[profiles[index].id] != nil
        }
    }
    func reload() {
        guard !busy else { return }
        error = nil; notice = nil
        do { try load(); try reconcile(document(readHosts())) }
        catch { self.error = HostsStrings.current.message(error) }
    }
    /// Prepare from a fresh disk snapshot. The same snapshot is compared both
    /// before the prompt and again by the privileged writer.
    func prepare(_ proposed: [HostsProfile]) throws -> Change? {
        guard !busy, AppFeature.hosts.isAvailable else { throw HostsFailure.storage }
        try load()
        let data = try readHosts(), doc = try document(data)
        let displayed = profiles
        try reconcile(doc)
        guard displayed == profiles else { throw HostsFailure.changed }
        try HostsSupport.validate(proposed)
        let replacement = Data(try HostsSupport.render(original: doc.original, profiles: proposed).utf8)
        if data == replacement {
            try persist(proposed, previous: previous)
            profiles = proposed
            return nil
        }
        return Change(expected: data, replacement: replacement, profiles: proposed,
                      before: profiles.filter(\.isEnabled).map { "# " + $0.name + "\n" + HostsSupport.body($0) }.joined(separator: "\n"),
                      after: proposed.filter(\.isEnabled).map { "# " + $0.name + "\n" + HostsSupport.body($0) }.joined(separator: "\n"),
                      conflicts: HostsSupport.conflicts(original: doc.original, profiles: proposed))
    }
    func restore() throws -> Change? {
        guard let previous else { throw HostsFailure.storage }
        return try prepare(previous)
    }
    func apply(_ change: Change) {
        guard !busy, AppFeature.hosts.isAvailable else { return }
        do {
            guard try readHosts() == change.expected else { throw HostsFailure.changed }
            let command = try HostsSupport.installCommand(expected: change.expected, replacement: change.replacement)
            guard let storage, PrivateFileStore.createDirectory(at: storage) else { throw HostsFailure.storage }
            // One private pre-write backup; restores use profile state so outside
            // edits are never rolled back along with our mappings.
            guard PrivateFileStore.write(change.expected, to: storage.appendingPathComponent("hosts.backup")) else { throw HostsFailure.storage }
            let old = profiles, oldPrevious = previous
            // Stage local state before authorization; failure rolls it back. If
            // interrupted, enabled status is always reconciled from the actual file.
            try persist(change.profiles, previous: old,
                        pending: Pending(before: old, previous: oldPrevious, resultHash: HostsSupport.digest(change.replacement)))
            busy = true; error = nil; notice = nil
            AdminShell.run(command, prompt: HostsStrings.current[.apply]) { ok in
                Task { @MainActor in
                    self.busy = false
                    let installed = (try? self.readHosts()) == change.replacement
                    if installed {
                        self.profiles = change.profiles; self.previous = old; self.canRestore = true
                        do { try self.persist(change.profiles, previous: old) }
                        catch { self.error = HostsStrings.current.message(error); return }
                        self.notice = HostsStrings.current[.applied]
                    } else {
                        do { try self.persist(old, previous: oldPrevious) }
                        catch { self.error = HostsStrings.current.message(error); return }
                        self.profiles = old
                        self.error = HostsStrings.current.message(ok ? HostsFailure.changed : HostsFailure.authorization)
                    }
                }
            }
        } catch { self.error = HostsStrings.current.message(error) }
    }
    func flushDNS() {
        guard !busy, AppFeature.hosts.isAvailable else { return }
        busy = true; error = nil; notice = nil
        AdminShell.run("/usr/bin/dscacheutil -flushcache && /usr/bin/killall -HUP mDNSResponder", prompt: HostsStrings.current[.flush]) { ok in
            Task { @MainActor in
                self.busy = false
                if ok { self.notice = HostsStrings.current[.flushDone] }
                else { self.error = HostsStrings.current[.authorization] }
            }
        }
    }
}
