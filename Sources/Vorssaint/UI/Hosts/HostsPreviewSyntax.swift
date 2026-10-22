// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

/// Presentation only: retain every character, including whitespace and comments.
enum HostsPreviewSyntax {
    static func highlight(_ text: String) -> AttributedString {
        var result = AttributedString()
        let lines = text.components(separatedBy: "\n")
        for (index, line) in lines.enumerated() {
            if index > 0 { result.append(AttributedString("\n")) }
            var styled = AttributedString(line)
            styled.foregroundColor = .primary

            let comment = line.firstIndex(of: "#") ?? line.endIndex
            let mapping = line[..<comment]
            if let address = mapping.split(whereSeparator: \.isWhitespace).first,
               HostsSupport.validAddress(String(address)),
               let range = styled.range(of: String(address)) {
                styled[range].foregroundColor = .blue
            }
            if comment < line.endIndex {
                let text = String(line[comment...])
                if let range = styled.range(of: text) {
                    let isBoundary = mapping.allSatisfy(\.isWhitespace)
                        && (text.hasPrefix(HostsSupport.prefix) || text.hasPrefix(HostsSupport.suffix))
                    styled[range].foregroundColor = isBoundary ? .purple : .secondary
                }
            }
            result.append(styled)
        }
        return result
    }
}
