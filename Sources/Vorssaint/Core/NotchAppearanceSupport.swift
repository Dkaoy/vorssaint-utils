// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Opaque dark backgrounds retain the island's existing white foregrounds.
enum NotchAppearance {
    static let defaultHex = "#18243B"
    struct RGB: Equatable {
        let red: Double
        let green: Double
        let blue: Double
        var luminance: Double {
            func linear(_ value: Double) -> Double {
                value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
        }
        func scaled(_ value: Double) -> RGB {
            RGB(red: red * value, green: green * value, blue: blue * value)
        }
    }
    static func rgb(_ value: String) -> RGB? {
        var hex = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.utf8.count == 6, hex.utf8.allSatisfy({
            (48...57).contains($0) || (65...70).contains($0) || (97...102).contains($0)
        }), let number = UInt32(hex, radix: 16) else { return nil }
        return RGB(red: Double((number >> 16) & 255) / 255,
                   green: Double((number >> 8) & 255) / 255,
                   blue: Double(number & 255) / 255)
    }
    static func effective(enabled: Bool, hex: String) -> RGB {
        let black = RGB(red: 0, green: 0, blue: 0)
        guard enabled, let selected = rgb(hex) else { return black }
        guard selected.luminance > 0.1 else { return selected }
        var lower = 0.0, upper = 1.0
        for _ in 0..<30 {
            let middle = (lower + upper) / 2
            if selected.scaled(middle).luminance > 0.1 { upper = middle }
            else { lower = middle }
        }
        return selected.scaled(lower)
    }
}
