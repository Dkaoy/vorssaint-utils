// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
// Standalone fixtures. The app's actual service is compiled against these
// minimal UI/authorization adapters; no real system file or prompt is used.
import AppKit
import Combine

enum AppLanguage { case enUS, zhHans, zhTW, zhHK }
final class L10n: ObservableObject {
    static let shared = L10n()
    var language = AppLanguage.enUS
}
enum AppFeature { case hosts; var isAvailable: Bool { true } }
enum AdminShell {
    static var handler: ((String, @escaping (Bool) -> Void) -> Void)?
    static func run(_ command: String, prompt: String, completion: @escaping (Bool) -> Void) {
        handler?(command, completion)
    }
}
@main struct HostsServiceTests {
    static var checks = 0
    static func expect(_ value: Bool, _ message: String) throws {
        checks += 1
        if !value { throw NSError(domain: "HostsServiceTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
    }
    @MainActor static func settled(_ service: HostsService) async throws {
        for _ in 0..<100 {
            if !service.busy { return }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        throw HostsFailure.authorization
    }
    @MainActor static func main() async throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent("HostsServiceTests-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: root) }
        let target = root.appendingPathComponent("hosts"), storage = root.appendingPathComponent("state")
        let original = "127.0.0.1 localhost\n# untouched\n"
        try Data(original.utf8).write(to: target)
        let service = HostsService(target: target, storage: storage)
        let initialSnapshot = try service.snapshot()
        try expect(initialSnapshot.text == original && initialSnapshot.document?.original == original,
                   "preview reads the full current file before loading any profiles")
        try expect(initialSnapshot.document?.managed == "" && !FileManager.default.fileExists(atPath: storage.path),
                   "preview works without profiles and creates no storage")
        service.reload()
        try expect(service.error == nil && service.profiles.isEmpty, "fresh load")
        let profile = HostsProfile(name: "Development", mappings: [.init(address: "127.0.0.1", domains: "app.test")])
        try expect(try service.prepare([profile]) == nil, "disabled save requires no privileged write")
        try expect(try String(contentsOf: target) == original, "saving configuration leaves hosts untouched")
        var enabled = profile; enabled.isEnabled = true
        let enabling = try service.prepare([enabled])!
        AdminShell.handler = { _, completion in completion(false) }
        service.apply(enabling)
        try await settled(service)
        try expect(!service.profiles[0].isEnabled && service.error != nil, "cancel leaves disabled and reports failure")
        let reloaded = HostsService(target: target, storage: storage)
        reloaded.reload()
        try expect(reloaded.profiles == [profile], "cancel rolls back durable state")
        AdminShell.handler = { command, completion in
            // Decode is not reimplemented; write the independently reviewed
            // replacement into our fixture to stand in for OS authorization.
            do { try enabling.replacement.write(to: target); completion(true) }
            catch { completion(false) }
        }
        service.apply(enabling)
        try await settled(service)
        try expect(service.profiles[0].isEnabled && service.canRestore, "successful enable updates state and backup")
        try expect(try Data(contentsOf: storage.appendingPathComponent("hosts.backup")) == Data(original.utf8), "prewrite backup")
        let fresh = HostsService(target: target, storage: storage)
        fresh.reload()
        try expect(fresh.error == nil && fresh.profiles[0].isEnabled, "enabled status survives restart")
        let enabledSnapshot = try fresh.snapshot()
        try expect(Data(enabledSnapshot.text.utf8) == enabling.replacement
                   && enabledSnapshot.document?.original == original
                   && enabledSnapshot.document?.managed.contains("app.test") == true,
                   "preview separates existing text and enabled mappings while keeping the complete file")
        let restore = try fresh.restore()!
        try expect(restore.profiles == [profile], "restore contains prior disabled configuration")
        try expect(String(decoding: restore.replacement, as: UTF8.self) == original, "restore only removes managed mappings")
        // Simulate an outside writer after the preview, before the prompt.
        try Data((String(decoding: enabling.replacement, as: UTF8.self) + "192.0.2.1 external.test\n").utf8).write(to: target)
        var prompted = false
        AdminShell.handler = { _, completion in prompted = true; completion(false) }
        fresh.apply(restore)
        try expect(!prompted && fresh.error != nil, "stale preview rejected before authorization")
        fresh.reload()
        let next = try fresh.restore()!
        try expect(String(decoding: next.replacement, as: UTF8.self) == original + "192.0.2.1 external.test\n", "external additions survive restore")
        // Durable journal: system write finished but app exited before callback.
        let pendingState = HostsService.State(profiles: [enabled], previous: [profile],
            pending: .init(before: [profile], previous: nil, resultHash: HostsSupport.digest(enabling.replacement)))
        try JSONEncoder().encode(pendingState).write(to: storage.appendingPathComponent("profiles.json"))
        let recovered = HostsService(target: target, storage: storage)
        recovered.reload()
        try expect(recovered.error == nil && recovered.profiles[0].isEnabled, "recover completed transaction despite external original changes")
        // Pending authorization never completed: restore prior local state.
        try Data(original.utf8).write(to: target)
        try JSONEncoder().encode(pendingState).write(to: storage.appendingPathComponent("profiles.json"))
        let cancelled = HostsService(target: target, storage: storage)
        cancelled.reload()
        try expect(cancelled.error == nil && cancelled.profiles == [profile], "recover interrupted authorization")
        // A different installation's UUID must never be silently removed.
        var unknown = enabled; unknown.id = UUID()
        try Data(HostsSupport.render(original: original, profiles: [unknown]).utf8).write(to: target)
        cancelled.reload()
        try expect(cancelled.error != nil, "unknown block refuses modification")
        // External modifications within known managed blocks are protected too.
        let tampered = String(decoding: enabling.replacement, as: UTF8.self).replacingOccurrences(of: "127.0.0.1\tapp.test", with: "192.0.2.9\tapp.test")
        try Data(tampered.utf8).write(to: target)
        cancelled.reload()
        try expect(cancelled.error != nil, "external managed edits refused")
        // Inspection must still work when local state or managed markers are damaged.
        let stateFile = storage.appendingPathComponent("profiles.json")
        let invalidState = Data("not valid profile JSON".utf8)
        try invalidState.write(to: stateFile)
        let broken = original + HostsSupport.prefix + "broken marker\n192.0.2.7 inspect.test\n"
        try Data(broken.utf8).write(to: target)
        var previewPrompted = false
        AdminShell.handler = { _, completion in previewPrompted = true; completion(false) }
        let inspection = HostsService(target: target, storage: storage)
        let brokenSnapshot = try inspection.snapshot()
        try expect(brokenSnapshot.text == broken && brokenSnapshot.document == nil,
                   "damaged markers remain inspectable as complete raw text")
        try expect(!previewPrompted && inspection.profiles.isEmpty && inspection.error == nil,
                   "inspection never authorizes, reconciles or changes profile state")
        try expect(try Data(contentsOf: stateFile) == invalidState && String(contentsOf: target) == broken,
                   "preview never persists state or rewrites the hosts file")
        let outside = "# updated outside\r\n127.0.0.1\tlocalhost"
        try Data(outside.utf8).write(to: target)
        try expect(try inspection.snapshot().text == outside,
                   "reloading the preview rereads disk and preserves CRLF, tabs and missing final newline")
        try Data([0xFF, 0xFE]).write(to: target)
        do {
            _ = try inspection.snapshot()
            try expect(false, "invalid UTF-8 must not silently replace bytes")
        } catch HostsFailure.malformed {
            try expect(true, "invalid UTF-8 is reported without replacement")
        }
        print("HostsServiceTests: \(checks) checks passed")
    }
}
