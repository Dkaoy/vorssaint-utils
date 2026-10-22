// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

@MainActor
struct HostsEditorView: View {
    @ObservedObject private var service: HostsService
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.controlActiveState) private var activeState
    @State private var query = ""
    @State private var draft: HostsProfile?
    @State private var change: HostsService.Change?
    @State private var deleting: HostsProfile?
    @State private var restoring = false
    init(service: HostsService? = nil) { self.service = service ?? .shared }
    private var s: HostsStrings { HostsStrings(language: l10n.language) }
    private var filtered: [HostsProfile] {
        service.profiles.filter { profile in
            query.isEmpty || ([profile.name, profile.note] + profile.mappings.map(\.domains))
                .contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                if let error = service.error { banner(error, icon: "exclamationmark.triangle.fill", color: .orange) }
                if let notice = service.notice { banner(notice, icon: "checkmark.circle.fill", color: .green) }
                if service.busy {
                    HStack(spacing: 10) { ProgressView().controlSize(.small); Text(s[.pending]).font(.callout) }
                }
                if service.profiles.isEmpty { emptyState }
                else {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                        TextField(s[.search], text: $query).textFieldStyle(.plain)
                        if !query.isEmpty { Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }.buttonStyle(.plain) }
                    }
                    .padding(11).background(.quaternary.opacity(0.45), in: RoundedRectangle(cornerRadius: 10))
                    LazyVStack(spacing: 12) { ForEach(filtered) { profile in card(profile) } }
                }
                footer
            }
            .padding(24)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear { service.reload() }
        .onChange(of: activeState) { _, value in if value == .key, draft == nil, change == nil { service.reload() } }
        .sheet(item: $draft) { profile in
            HostsProfileEditor(profile: profile) { edited in
                var profiles = service.profiles
                if let index = profiles.firstIndex(where: { $0.id == edited.id }) { profiles[index] = edited }
                else { profiles.append(edited) }
                review(profiles)
            }
        }
        .sheet(item: $change) { pending in
            HostsChangePreview(change: pending) {
                change = nil
                service.apply(pending)
            }
        }
        .alert(s[.delete], isPresented: Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })) {
            Button(s[.cancel], role: .cancel) { deleting = nil }
            Button(s[.delete], role: .destructive) {
                guard let deleting else { return }
                review(service.profiles.filter { $0.id != deleting.id })
                self.deleting = nil
            }
        } message: { Text(s[.deleteMessage]) }
        .alert(s[.restore], isPresented: $restoring) {
            Button(s[.cancel], role: .cancel) {}
            Button(s[.restore]) { do { change = try service.restore() } catch { service.error = s.message(error) } }
        } message: { Text(s[.restoreMessage]) }
    }
    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: "network")
                    .font(.system(size: 25, weight: .medium)).foregroundStyle(Color.accentColor)
                    .frame(width: 54, height: 54)
                    .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))
                VStack(alignment: .leading, spacing: 5) {
                    Text(s[.title]).font(.title2.bold())
                    Text("\(service.profiles.filter(\.isEnabled).count) / \(service.profiles.count) · \(s[.enabled])")
                        .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { draft = HostsProfile() } label: { Label(s[.add], systemImage: "plus") }
                    .buttonStyle(.borderedProminent).disabled(service.busy)
            }
            Text(s[.caption]).font(.callout).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
        }
    }
    private func card(_ profile: HostsProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: profile.isEnabled ? "checkmark.shield.fill" : "server.rack")
                    .font(.title3).foregroundStyle(profile.isEnabled ? Color.accentColor : .secondary)
                    .frame(width: 36, height: 36)
                    .background(profile.isEnabled ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name).font(.headline).lineLimit(2)
                    Text("\(profile.mappings.count) \(s[.count])").font(.caption).foregroundStyle(.secondary)
                }
                Spacer(minLength: 8)
                Toggle(s[.enabled], isOn: Binding(get: { profile.isEnabled }, set: { enabled in
                    var proposed = service.profiles
                    guard let index = proposed.firstIndex(where: { $0.id == profile.id }) else { return }
                    proposed[index].isEnabled = enabled
                    review(proposed)
                }))
                .labelsHidden().toggleStyle(.switch).controlSize(.small)
                .accessibilityLabel(profile.name + " · " + s[.enabled])
                Menu {
                    Button(s[.edit]) { draft = profile }
                    Divider()
                    Button(s[.delete], role: .destructive) { deleting = profile }
                } label: { Image(systemName: "ellipsis") }
                .menuStyle(.borderlessButton)
                .fixedSize().accessibilityLabel(s[.edit])
            }
            if !profile.note.isEmpty { Text(profile.note).font(.callout).foregroundStyle(.secondary) }
            Divider()
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(profile.mappings.prefix(3)) { row in
                        HStack(alignment: .top, spacing: 12) {
                            Text(row.address).foregroundStyle(.secondary)
                            Text(row.domains).lineLimit(1)
                        }.font(.system(.caption, design: .monospaced))
                    }
                    if profile.mappings.count > 3 { Text("+\(profile.mappings.count - 3)").font(.caption).foregroundStyle(.tertiary) }
                }
                Spacer(minLength: 0)
                Text(s[profile.isEnabled ? .enabled : .disabled])
                    .font(.caption.weight(.medium))
                    .foregroundStyle(profile.isEnabled ? Color.accentColor : .secondary)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(profile.isEnabled ? Color.accentColor.opacity(0.1) : Color.secondary.opacity(0.08), in: Capsule())
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(profile.isEnabled ? Color.accentColor.opacity(0.35) : Color.secondary.opacity(0.15)))
        .disabled(service.busy)
    }
    private var emptyState: some View {
        VStack(spacing: 13) {
            Image(systemName: "point.3.connected.trianglepath.dotted").font(.system(size: 42)).foregroundStyle(Color.accentColor.opacity(0.7))
            Text(s[.empty]).font(.headline)
            Text(s[.emptyCaption]).font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
            Button(s[.add]) { draft = HostsProfile() }.buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 38).padding(.horizontal, 24)
        .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))
        .disabled(service.busy)
    }
    private var footer: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Button { service.reload() } label: { Label(s[.refresh], systemImage: "arrow.clockwise") }
                Button(s[.flush]) { service.flushDNS() }
                Spacer()
                Menu {
                    Button(s[.restore]) { restoring = true }.disabled(!service.canRestore)
                    Button(s[.disableAll]) {
                        review(service.profiles.map { var profile = $0; profile.isEnabled = false; return profile })
                    }.disabled(!service.profiles.contains(where: \.isEnabled))
                } label: { Image(systemName: "ellipsis.circle") }.menuStyle(.borderlessButton)
                .fixedSize()
            }.disabled(service.busy)
            Label(s[.readOnly], systemImage: "lock.shield").font(.caption).foregroundStyle(.secondary)
            Text(s[.notice]).font(.caption).foregroundStyle(.secondary)
            Text(s[.backup]).font(.caption).foregroundStyle(.tertiary)
        }
    }
    private func banner(_ message: String, icon: String, color: Color) -> some View {
        Label(message, systemImage: icon).font(.callout).foregroundStyle(color)
            .frame(maxWidth: .infinity, alignment: .leading).padding(12)
            .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }
    private func review(_ profiles: [HostsProfile]) {
        do { change = try service.prepare(profiles) }
        catch { service.error = s.message(error) }
    }
}

struct HostsProfileEditor: View {
    let profile: HostsProfile
    let save: (HostsProfile) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var draft: HostsProfile
    @State private var discard = false
    @State private var attempted = false
    private var s: HostsStrings { .current }
    init(profile: HostsProfile, save: @escaping (HostsProfile) -> Void) {
        self.profile = profile; self.save = save; _draft = State(initialValue: profile)
    }
    private var validName: Bool {
        !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && draft.name.count <= 100 && draft.note.count <= 500
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label(s[.edit], systemImage: "network").font(.title3.bold())
                Spacer()
                Text(s[draft.isEnabled ? .enabled : .disabled]).font(.caption).foregroundStyle(.secondary)
            }.padding(22)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(s[.name]).font(.callout.weight(.medium))
                        TextField("Development", text: $draft.name).textFieldStyle(.roundedBorder)
                        TextField(s[.note], text: $draft.note).textFieldStyle(.roundedBorder)
                        if attempted && !validName { Text(s[.invalidName]).font(.caption).foregroundStyle(.red) }
                    }
                    HStack {
                        Text(s[.mappings]).font(.headline)
                        Spacer()
                        Button { draft.mappings.append(HostsMapping()) } label: { Label(s[.addRow], systemImage: "plus") }
                            .disabled(draft.mappings.count >= 500)
                    }
                    VStack(spacing: 12) {
                        ForEach($draft.mappings) { $row in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 10) {
                                    TextField("127.0.0.1 / ::1", text: $row.address)
                                        .frame(width: 150)
                                    TextField(s[.domains], text: $row.domains)
                                    Button(role: .destructive) { draft.mappings.removeAll { $0.id == row.id } } label: { Image(systemName: "minus.circle") }
                                        .buttonStyle(.plain).disabled(draft.mappings.count <= 1)
                                        .accessibilityLabel(s[.delete])
                                }.textFieldStyle(.roundedBorder).font(.system(.body, design: .monospaced))
                                if !HostsSupport.valid(row), attempted || !row.domains.isEmpty {
                                    Text(s[.invalidRow]).font(.caption).foregroundStyle(.red)
                                }
                            }
                        }
                    }.padding(14).background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
                }.padding(22)
            }
            Divider()
            HStack {
                Text(s[.readOnly]).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button(s[.cancel]) { if draft != profile { discard = true } else { dismiss() } }.keyboardShortcut(.cancelAction)
                Button(s[.save]) {
                    attempted = true
                    guard validName, (try? HostsSupport.validate([draft])) != nil else { return }
                    draft.name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    dismiss()
                    // Present review after this sheet is fully dismissed.
                    let result = draft
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { save(result) }
                }.buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction)
            }.padding(18)
        }
        .frame(width: 680, height: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .interactiveDismissDisabled(draft != profile)
        .confirmationDialog(s[.closeWarning], isPresented: $discard) {
            Button(s[.discard], role: .destructive) { dismiss() }
            Button(s[.cancel], role: .cancel) {}
        }
    }
}

struct HostsChangePreview: View {
    let change: HostsService.Change
    let apply: () -> Void
    @Environment(\.dismiss) private var dismiss
    private var s: HostsStrings { .current }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(s[.preview], systemImage: "checkmark.shield").font(.title3.bold())
            Text(s[.confirmation]).font(.callout).foregroundStyle(.secondary)
            if !change.conflicts.isEmpty {
                Label(s[.conflict], systemImage: "exclamationmark.triangle.fill").font(.callout).foregroundStyle(.orange)
                ScrollView { Text(change.conflicts.joined(separator: ", ")).font(.system(.caption, design: .monospaced)).textSelection(.enabled) }
                    .frame(maxHeight: 55)
            }
            HStack(alignment: .top, spacing: 14) {
                preview(s[.original], content: change.before)
                preview(s[.managed], content: change.after)
            }
            HStack {
                Image(systemName: "lock.fill").foregroundStyle(.secondary)
                Text("/etc/hosts").font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                Spacer()
                Button(s[.cancel]) { dismiss() }.keyboardShortcut(.cancelAction)
                Button(s[.apply]) { apply() }.buttonStyle(.borderedProminent).keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 720, height: 480)
            .background(Color(nsColor: .windowBackgroundColor))
    }
    private func preview(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading) {
                    Text(content.isEmpty ? "—" : content.replacingOccurrences(of: "\t", with: "    "))
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(nsColor: .textBackgroundColor), in: RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.secondary.opacity(0.15)))
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
