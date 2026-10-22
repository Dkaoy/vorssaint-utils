// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

/// Static identity of the app, shared by UI, notifications and tooling.
enum AppInfo {
    static let name = "Vorssaint"
    static let copyright = "© 2026 Vorssaint"
    static let websiteURL = URL(string: "https://vorssaint.com")!
    static let repositoryURL = URL(string: "https://github.com/Dkaoy/vorssaint-utils")!
    static let coffeeURL = URL(string: "https://buymeacoffee.com/vorssaint")!
    static let discordURL = URL(string: "https://discord.gg/M6BwWH4BJp")!
    static let socialURL = URL(string: "https://x.com/vorssaint")!

    /// The bundle version. The fallback only applies to the bare binary
    /// (e.g. `--selftest`), never the shipped app, which reads its Info.plist.
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
    }

    /// True for the local "Vorssaint (Developer)" build (bundle id ends in `.dev`).
    /// It is never published and never auto-updates; all work is tested here first.
    static var isDeveloperBuild: Bool {
        (Bundle.main.bundleIdentifier ?? "").hasSuffix(".dev")
    }

    /// True when the current version is a pre-release (e.g. 3.3.4-beta.1 or 3.3.4-rc.1).
    static var isBeta: Bool {
        if isDeveloperBuild && UserDefaults.standard.bool(forKey: DefaultsKey.simulateBetaUI) {
            return true
        }
        let v = version.lowercased()
        return v.contains("-beta") || v.contains("-rc") || v.contains("-alpha")
    }

    /// The git commit a Developer build was compiled from, e.g. "ed2ebba · 2026-06-15 21:30"
    /// (or with a "-dirty" suffix on the SHA for uncommitted changes). build.sh stamps
    /// this into the Developer bundle only, so you can confirm at a glance that the
    /// running dev app matches the source you are about to change. nil in the official app.
    static var buildCommit: String? {
        Bundle.main.object(forInfoDictionaryKey: "VorssaintBuildCommit") as? String
    }
}

/// This fork distributes ad-hoc signed builds. Never enter the upstream installer.
enum ForkUpdateDistribution {
    static let repository = "Dkaoy/vorssaint-utils"
    static let manualDownloadOnly = true
    static var releasesURL: URL { AppInfo.repositoryURL.appendingPathComponent("releases") }
    static func releaseURL(version: String) -> URL {
        releasesURL.appendingPathComponent("tag").appendingPathComponent("v" + version)
    }
    static func downloadLabel(_ language: AppLanguage) -> String {
        switch language {
        case .zhHans: return "前往下载"
        case .zhTW, .zhHK: return "前往下載"
        default: return "Download Manually"
        }
    }
    static func notice(_ language: AppLanguage) -> String {
        switch language {
        case .zhHans: return "此分支提供未公证安装包。更新将打开 GitHub 发布页，请下载后手动安装。"
        case .zhTW, .zhHK: return "此分支提供未公證安裝包。更新將開啟 GitHub 發布頁，請下載後手動安裝。"
        default: return "This fork is not notarized. Updates open GitHub Releases for manual download and installation."
        }
    }
}
