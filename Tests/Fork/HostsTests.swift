// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
import Foundation
import Darwin

@main
struct HostsTests {
    static var checks = 0
    static func expect(_ condition: Bool, _ message: String) throws {
        checks += 1
        if !condition { throw NSError(domain: "HostsTests", code: 1, userInfo: [NSLocalizedDescriptionKey: message]) }
    }
    static func rejects(_ work: () throws -> Void, _ message: String) throws {
        do { try work() } catch { try expect(true, message); return }
        try expect(false, message)
    }
    static func run(_ script: String) throws -> Int32 {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", script]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run(); process.waitUntilExit()
        return process.terminationStatus
    }
    static func main() throws {
        let row = HostsMapping(address: "127.0.0.1", domains: "api.test app.test")
        let profile = HostsProfile(name: "Dev ' $(touch PWNED)", mappings: [row], isEnabled: true)
        let other = HostsProfile(name: "IPv6", mappings: [.init(address: "::1", domains: "ipv6.test")], isEnabled: true)
        for original in ["", "# existing\n127.0.0.1 localhost\n", "# no final newline", "# CRLF\r\n127.0.0.1 localhost\r\n", "# 中文\n"] {
            let text = try HostsSupport.render(original: original, profiles: [profile, other])
            let doc = try HostsSupport.parse(text)
            try expect(doc.original == original, "preserve exact original, including newline state")
            try expect(doc.blocks.count == 2, "multiple independent blocks")
            try expect(doc.blocks[profile.id] == HostsSupport.body(profile), "correct mappings")
            try expect(doc.managed == text[text.range(of: HostsSupport.prefix)!.lowerBound...],
                       "read-only managed preview preserves markers, mapping order and exact text")
            let removed = try HostsSupport.render(original: doc.original, profiles: [])
            try expect(removed == original, "disable all recovers original bytes")
            let retained = try HostsSupport.render(original: doc.original, profiles: [other])
            try expect(try HostsSupport.parse(retained).blocks[other.id] == HostsSupport.body(other), "disable one retains the other")
            let external = text + "192.0.2.2 external.test\n"
            try expect(try HostsSupport.parse(external).original == original + "192.0.2.2 external.test\n", "preserve externally appended content")
        }
        try expect(HostsSupport.validAddress("::ffff:192.0.2.1"), "IPv6 mapped IPv4")
        for address in ["127.1", "999.1.1.1", "1.2.3.4;id", "::1\n", "https://1.2.3.4"] {
            try expect(!HostsSupport.validAddress(address), "reject malformed IP")
        }
        for domain in ["localhost", "API.Example.test", "example.test.", "a-b.test"] {
            try expect(HostsSupport.validDomain(domain), "valid domain")
        }
        for domain in ["*.test", "https://app.test", "foo/bar", "a..test", "-a.test", "a_.test", "127.0.0.1", "$(id)", "#comment"] {
            try expect(!HostsSupport.validDomain(domain), "reject unsafe domain")
        }
        let rendered = try HostsSupport.render(original: "", profiles: [profile])
        try rejects({ _ = try HostsSupport.parse(rendered.replacingOccurrences(of: HostsSupport.suffix, with: "# broken ")) }, "reject incomplete block")
        try rejects({ _ = try HostsSupport.parse(rendered + rendered) }, "reject duplicate marker ids")
        try rejects({ _ = try HostsSupport.parse(HostsSupport.suffix + profile.id.uuidString + "\n") }, "reject orphan terminator")
        try rejects({ _ = try HostsSupport.parse(HostsSupport.prefix + profile.id.uuidString + " join=1\n") }, "reject invalid joined marker")
        try rejects({ _ = try HostsSupport.render(original: String(repeating: "x", count: HostsSupport.limit), profiles: [profile]) }, "enforce file limit")
        try rejects({ try HostsSupport.validate([profile, profile]) }, "reject duplicate profile ids")
        var invalid = profile; invalid.name = " "
        try rejects({ try HostsSupport.validate([invalid]) }, "reject empty name")
        var duplicate = other
        duplicate.mappings = [.init(address: "192.0.2.1", domains: "API.TEST.")]
        let conflicts = HostsSupport.conflicts(original: "127.0.0.1 app.test # keep\n", profiles: [profile, duplicate])
        try expect(conflicts == ["api.test", "app.test"], "detect unmanaged and cross-profile conflicts case-insensitively")
        // Exercise the actual transaction in a private temp directory, with only
        // fixed system paths and expected owner replaced. Never touch real hosts.
        let temp = FileManager.default.temporaryDirectory.appendingPathComponent("HostsTests-" + UUID().uuidString)
        try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: false)
        defer { try? FileManager.default.removeItem(at: temp) }
        let target = temp.appendingPathComponent("hosts"), lock = temp.appendingPathComponent("lock")
        let before = Data("# original\n127.0.0.1 localhost\n".utf8)
        let after = Data(try HostsSupport.render(original: String(decoding: before, as: UTF8.self), profiles: [profile]).utf8)
        let command = try HostsSupport.installCommand(expected: before, replacement: after)
        try expect(!command.contains(profile.name), "user names never enter shell source")
        let sandboxed = command.replacingOccurrences(of: "/private/etc/hosts", with: target.path)
            .replacingOccurrences(of: "/private/etc/.vorssaint-hosts.lock", with: lock.path)
            .replacingOccurrences(of: "/private/etc/.hosts.vorssaint.XXXXXX", with: temp.appendingPathComponent("stage.XXXXXX").path)
            .replacingOccurrences(of: "\" = 0 ]", with: "\" = \(getuid()) ]")
        try before.write(to: target)
        try FileManager.default.setAttributes([.posixPermissions: 0o640], ofItemAtPath: target.path)
        try expect(try run(sandboxed) == 0, "transaction succeeds")
        try expect(try Data(contentsOf: target) == after, "exact content installed")
        let mode = try FileManager.default.attributesOfItem(atPath: target.path)[.posixPermissions] as? NSNumber
        try expect(mode?.intValue == 0o640, "preserve permissions")
        try expect(!FileManager.default.fileExists(atPath: lock.path), "release lock")
        try expect(try run(sandboxed) != 0, "reject stale snapshot")
        try expect(try Data(contentsOf: target) == after, "stale write preserves external content")
        try before.write(to: target)
        try FileManager.default.createDirectory(at: lock, withIntermediateDirectories: false)
        try expect(try run(sandboxed) != 0, "refuse concurrent writer")
        try expect(try Data(contentsOf: target) == before, "lock refusal leaves target unchanged")
        try FileManager.default.removeItem(at: lock)
        try FileManager.default.removeItem(at: target)
        let victim = temp.appendingPathComponent("victim")
        try before.write(to: victim)
        try FileManager.default.createSymbolicLink(at: target, withDestinationURL: victim)
        try expect(try run(sandboxed) != 0, "reject symlink target")
        try expect(try Data(contentsOf: victim) == before, "symlink victim untouched")
        print("HostsTests: \(checks) checks passed")
    }
}
