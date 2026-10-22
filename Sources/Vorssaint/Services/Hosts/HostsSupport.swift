// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation
import Darwin
import CryptoKit

struct HostsMapping: Codable, Identifiable, Equatable {
    var id = UUID()
    var address = "127.0.0.1"
    var domains = ""
}

struct HostsProfile: Codable, Identifiable, Equatable {
    var id = UUID()
    var name = ""
    var note = ""
    var mappings = [HostsMapping()]
    var isEnabled = false
}

enum HostsFailure: String, Error {
    case invalid, malformed, unknown, changed, storage, authorization, tooLarge
}

/// Byte-preserving removal of our marked blocks, with all unrelated text kept
/// verbatim. A join flag owns the one newline needed after an unterminated file.
enum HostsSupport {
    static let prefix = "# >>> Vorssaint Hosts "
    static let suffix = "# <<< Vorssaint Hosts "
    static let limit = 64 * 1024
    struct Document {
        var original: String
        var blocks: [UUID: String]
        var managed: String
    }
    struct Snapshot {
        let text: String
        let document: Document?
        init(text: String) {
            self.text = text
            document = try? HostsSupport.parse(text)
        }
    }
    static func digest(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
    static func tokens(_ domains: String) -> [String] {
        domains.split(whereSeparator: \.isWhitespace).map { String($0).lowercased() }
    }
    static func validAddress(_ value: String) -> Bool {
        var ipv4 = in_addr(), ipv6 = in6_addr()
        return value.withCString { inet_pton(AF_INET, $0, &ipv4) == 1 || inet_pton(AF_INET6, $0, &ipv6) == 1 }
    }
    static func validDomain(_ value: String) -> Bool {
        let text = value.hasSuffix(".") ? String(value.dropLast()) : value
        guard !text.isEmpty, text.utf8.count <= 253, !validAddress(text) else { return false }
        return text.split(separator: ".", omittingEmptySubsequences: false).allSatisfy {
            $0.utf8.count <= 63 && $0.range(of: "^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$", options: .regularExpression) != nil
        }
    }
    static func valid(_ row: HostsMapping) -> Bool {
        let domains = tokens(row.domains)
        return validAddress(row.address) && !domains.isEmpty && domains.allSatisfy(validDomain)
            && domains.count <= 32
    }
    static func validate(_ profiles: [HostsProfile]) throws {
        guard profiles.count <= 100, Set(profiles.map(\.id)).count == profiles.count else { throw HostsFailure.invalid }
        for profile in profiles {
            guard !profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  profile.name.count <= 100, profile.note.count <= 500,
                  !profile.mappings.isEmpty, profile.mappings.count <= 500,
                  profile.mappings.allSatisfy(valid) else { throw HostsFailure.invalid }
        }
    }
    static func body(_ profile: HostsProfile) -> String {
        profile.mappings.map { $0.address + "\t" + tokens($0.domains).joined(separator: " ") + "\n" }.joined()
    }
    static func parse(_ text: String) throws -> Document {
        guard text.utf8.count <= limit, !text.contains("\0") else { throw HostsFailure.tooLarge }
        var original = "", managed = "", blocks: [UUID: String] = [:]
        var open: UUID?, block = ""
        var remainder = text[...]
        while !remainder.isEmpty {
            let end = remainder.firstIndex(of: "\n").map { remainder.index(after: $0) } ?? remainder.endIndex
            let line = String(remainder[..<end])
            remainder = remainder[end...]
            if line.hasPrefix(prefix) {
                guard open == nil else { throw HostsFailure.malformed }
                let fields = line.dropFirst(prefix.count).trimmingCharacters(in: .newlines).split(separator: " ")
                guard fields.count == 2, let id = UUID(uuidString: String(fields[0])),
                      blocks[id] == nil, ["join=0", "join=1"].contains(String(fields[1])) else { throw HostsFailure.malformed }
                if fields[1] == "join=1" {
                    guard original.hasSuffix("\n") else { throw HostsFailure.malformed }
                    original.removeLast()
                }
                open = id; block = ""
                managed += line
            } else if line.hasPrefix(suffix) {
                guard let id = open,
                      line == suffix + id.uuidString + "\n" else { throw HostsFailure.malformed }
                blocks[id] = block; open = nil
                managed += line
            } else if line.hasPrefix("# >>> Vorssaint") || line.hasPrefix("# <<< Vorssaint") {
                // Partial or edited boundary markers must never become deletable text.
                throw HostsFailure.malformed
            } else if open != nil {
                block += line
                managed += line
            } else { original += line }
        }
        guard open == nil else { throw HostsFailure.malformed }
        return Document(original: original, blocks: blocks, managed: managed)
    }
    static func render(original: String, profiles: [HostsProfile]) throws -> String {
        try validate(profiles)
        var text = original
        for profile in profiles where profile.isEnabled {
            let joins = !text.isEmpty && !text.hasSuffix("\n")
            if joins { text += "\n" }
            text += prefix + profile.id.uuidString + " join=\(joins ? 1 : 0)\n"
            text += body(profile)
            text += suffix + profile.id.uuidString + "\n"
        }
        guard text.utf8.count <= limit else { throw HostsFailure.tooLarge }
        return text
    }
    /// Warn about both duplicates and differing IPs, including unmanaged entries.
    static func conflicts(original: String, profiles: [HostsProfile]) -> [String] {
        var seen = Set<String>(), conflicts = Set<String>()
        func add(_ domains: [String]) {
            for value in domains {
                let key = value.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
                if !seen.insert(key).inserted { conflicts.insert(key) }
            }
        }
        for line in original.split(separator: "\n") {
            let data = line.split(separator: "#", maxSplits: 1, omittingEmptySubsequences: false)[0]
            let parts = data.split(whereSeparator: \.isWhitespace).map(String.init)
            if parts.count > 1, validAddress(parts[0]) { add(Array(parts.dropFirst())) }
        }
        for profile in profiles where profile.isEnabled {
            for row in profile.mappings { add(tokens(row.domains)) }
        }
        return conflicts.sorted()
    }
    /// Inline payload contains base64 only. No profile name, domain or user path
    /// becomes shell source. Root creates the lock and staging file in /private/etc.
    /// Compare again inside the privileged transaction to detect external writers.
    static func installCommand(expected: Data, replacement: Data) throws -> String {
        guard expected.count <= limit, replacement.count <= limit else { throw HostsFailure.tooLarge }
        let expectedHash = digest(expected), resultHash = digest(replacement)
        return """
        set -eu
        PATH=/usr/bin:/bin:/usr/sbin:/sbin
        export PATH
        target=/private/etc/hosts
        lock=/private/etc/.vorssaint-hosts.lock
        [ -f "$target" ] && [ ! -L "$target" ]
        [ "$(/usr/bin/stat -f %u "$target")" = 0 ]
        /bin/mkdir -m 700 "$lock"
        stage=''
        trap '[ -z "$stage" ] || /bin/rm -f "$stage"; /bin/rmdir "$lock"' EXIT
        trap 'exit 1' HUP INT TERM
        hash() { /usr/bin/shasum -a 256 "$target" | /usr/bin/awk '{print $1}'; }
        [ "$(hash)" = '\(expectedHash)' ]
        stage="$(/usr/bin/mktemp /private/etc/.hosts.vorssaint.XXXXXX)"
        /bin/cp -p "$target" "$stage"
        /usr/bin/printf '%s' '\(replacement.base64EncodedString())' | /usr/bin/base64 -D > "$stage"
        [ "$(/usr/bin/shasum -a 256 "$stage" | /usr/bin/awk '{print $1}')" = '\(resultHash)' ]
        [ -f "$target" ] && [ ! -L "$target" ]
        [ "$(hash)" = '\(expectedHash)' ]
        /bin/mv -f "$stage" "$target"
        stage=''
        """
    }
}
