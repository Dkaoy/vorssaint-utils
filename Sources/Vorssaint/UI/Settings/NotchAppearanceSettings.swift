// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit
import SwiftUI

extension NotchAppearance {
    static func color(enabled: Bool, hex: String) -> Color {
        let value = effective(enabled: enabled, hex: hex)
        return Color(red: value.red, green: value.green, blue: value.blue)
    }
}

/// Shared by the live host and all settings previews; AppStorage updates live.
struct NotchBackgroundFill: View {
    @AppStorage(DefaultsKey.notchCustomBackgroundEnabled) private var enabled = false
    @AppStorage(DefaultsKey.notchBackgroundColor) private var hex = NotchAppearance.defaultHex
    var body: some View { NotchAppearance.color(enabled: enabled, hex: hex) }
}

struct NotchAppearanceSettings: View {
    @ObservedObject private var l10n = L10n.shared
    @AppStorage(DefaultsKey.notchCustomBackgroundEnabled) private var enabled = false
    @AppStorage(DefaultsKey.notchBackgroundColor) private var hex = NotchAppearance.defaultHex
    private var s: NotchAppearanceStrings { NotchAppearanceStrings(language: l10n.language) }
    private let presets = ["#000000", "#18243B", "#153B35", "#3E254A", "#482D25"]
    private var selection: Binding<Color> {
        Binding(get: {
            let rgb = NotchAppearance.rgb(hex) ?? NotchAppearance.rgb(NotchAppearance.defaultHex)!
            return Color(red: rgb.red, green: rgb.green, blue: rgb.blue)
        }, set: { value in
            guard let color = NSColor(value).usingColorSpace(.sRGB) else { return }
            let values = [color.redComponent, color.greenComponent, color.blueComponent]
            guard values.allSatisfy({ $0.isFinite }) else { return }
            let bytes = values.map { Int((min(1, max(0, $0)) * 255).rounded()) }
            hex = String(format: "#%02X%02X%02X", bytes[0], bytes[1], bytes[2])
        })
    }
    var body: some View {
        SettingsCard(title: s[.title]) {
            Toggle(s[.enabled], isOn: $enabled).toggleStyle(.switch)
            HStack(spacing: 12) {
                ForEach(presets.indices, id: \.self) { index in
                    Button { hex = presets[index] } label: {
                        Circle().fill(NotchAppearance.color(enabled: true, hex: presets[index]))
                            .frame(width: 28, height: 28)
                            .overlay(Circle().strokeBorder(Color.primary.opacity(0.18), lineWidth: 1))
                            .padding(4)
                            .overlay(Circle().strokeBorder(hex.uppercased() == presets[index] ? Color.accentColor : .clear, lineWidth: 2))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(s.preset(index))
                    .accessibilityValue(hex.uppercased() == presets[index] ? s[.selected] : "")
                    .help(s.preset(index))
                }
                Spacer(minLength: 8)
                ColorPicker(s[.custom], selection: selection, supportsOpacity: false)
                    .fixedSize()
            }.disabled(!enabled)
            Text(s[enabled ? .hint : .defaultHint])
                .font(.caption).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(NotchAppearance.color(enabled: enabled, hex: hex))
                    .frame(width: 28, height: 18)
                    .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(Color.secondary.opacity(0.2)))
                Text(enabled ? hex.uppercased() : "#000000")
                    .font(.system(.caption, design: .monospaced)).foregroundStyle(.secondary)
                Spacer()
                Button(s[.reset]) { enabled = false; hex = NotchAppearance.defaultHex }
                    .disabled(!enabled && hex == NotchAppearance.defaultHex)
            }
        }
    }
}

private struct NotchAppearanceStrings {
    enum Key { case title, enabled, custom, hint, defaultHint, reset, selected }
    let language: AppLanguage
    private func localized(_ chinese: String, _ english: String) -> String {
        switch language {
        case .zhHans: return chinese
        case .zhTW, .zhHK: return chinese.applyingTransform(StringTransform("Hans-Hant"), reverse: false) ?? chinese
        default: return english
        }
    }
    subscript(_ key: Key) -> String {
        switch key {
        case .title: return localized("背景颜色", "Background Color")
        case .enabled: return localized("使用自选背景色", "Use custom background color")
        case .custom: return localized("自定义颜色", "Custom Color")
        case .hint: return localized("自选颜色使用纯色背景，浅色会自动调暗以保持文字清晰。关闭后恢复原有透明或玻璃效果；实体摄像头刘海仍为黑色。", "Custom colors use a solid background. Light colors are darkened for readable text. Turn this off to restore transparency or glass. The physical camera cutout stays black.")
        case .defaultHint: return localized("默认沿用黑色背景及原有透明、玻璃选项。启用后可选择预设色或自定义颜色。", "Keep the default black background and existing transparency or glass options, or enable a preset or custom color.")
        case .reset: return localized("恢复默认", "Restore Default")
        case .selected: return localized("已选中", "Selected")
        }
    }
    func preset(_ index: Int) -> String {
        let chinese = ["经典黑", "深海蓝", "松针绿", "暮光紫", "暖棕色"]
        let english = ["Black", "Deep Blue", "Forest Green", "Twilight Purple", "Warm Brown"]
        return localized(chinese[index], english[index])
    }
}
