// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint
import Foundation

@main struct NotchAppearanceTests {
    static var checks = 0
    static func expect(_ value: Bool, _ message: String) {
        checks += 1
        guard value else { fatalError(message) }
    }
    static func main() {
        let black = NotchAppearance.RGB(red: 0, green: 0, blue: 0)
        expect(NotchAppearance.effective(enabled: false, hex: "#FFFFFF") == black,
               "disabled custom color always restores black")
        expect(NotchAppearance.rgb("  #abcdef\n") == NotchAppearance.rgb("ABCDEF"), "hex is case insensitive and trimmed")
        for invalid in ["", "#FFF", "#FFFFFF00", "#GG0000", "+00000", "＃000000", "#000000\0", String(repeating: "F", count: 10000)] {
            expect(NotchAppearance.rgb(invalid) == nil, "invalid stored colors are rejected")
            expect(NotchAppearance.effective(enabled: true, hex: invalid) == black, "corrupted preferences fall back to black")
        }
        for hex in ["#000000", "#18243B", "#153B35", "#3E254A", "#482D25"] {
            expect(NotchAppearance.effective(enabled: true, hex: hex) == NotchAppearance.rgb(hex), "dark presets keep their exact colors")
        }
        for red in [0, 51, 128, 200, 255] {
            for green in [0, 51, 128, 200, 255] {
                for blue in [0, 51, 128, 200, 255] {
                    let hex = String(format: "#%02X%02X%02X", red, green, blue)
                    let color = NotchAppearance.effective(enabled: true, hex: hex)
                    expect(color.luminance <= 0.100000001 && 1.05 / (color.luminance + 0.05) >= 6.999999,
                           "custom colors keep at least 7:1 contrast against white")
                }
            }
        }
        print("NotchAppearanceTests: \(checks) checks passed")
    }
}
