// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct HostsStrings {
    enum Key: CaseIterable {
        case title, caption, add, empty, emptyCaption, name, note, mappings, addRow, domains
        case enabled, disabled, edit, delete, cancel, save, refresh, preview, apply, original, managed
        case notice, invalidRow, invalidName, pending, backup, restore, disableAll, flush, flushDone
        case confirmation, conflict, failure, changed, malformed, unknown, storage, authorization, tooLarge
        case closeWarning, discard, count, deleteMessage, restoreMessage, status, readOnly, search, applied
    }
    let language: AppLanguage
    static var current: HostsStrings { HostsStrings(language: L10n.shared.language) }
    subscript(_ key: Key) -> String {
        let pair: (String, String)
        switch key {
        case .title: pair = ("Hosts 配置", "Hosts Profiles")
        case .caption: pair = ("用独立配置管理域名映射，启用后追加到 hosts，保留原有内容。", "Manage domain mappings in profiles. Enabled profiles are appended to hosts; existing content is preserved.")
        case .add: pair = ("新增配置", "New Profile")
        case .empty: pair = ("为你的环境添加一份配置", "A profile for every environment")
        case .emptyCaption: pair = ("将开发、测试或本地服务的域名映射放在一起，按需启用。", "Group mappings for development, testing or local services and enable them when needed.")
        case .name: pair = ("配置名称", "Profile name")
        case .note: pair = ("说明（可选）", "Description (optional)")
        case .mappings: pair = ("域名映射", "Domain mappings")
        case .addRow: pair = ("添加映射", "Add Mapping")
        case .domains: pair = ("域名，多个用空格分隔", "Domains, separated by spaces")
        case .enabled: pair = ("已启用", "Enabled")
        case .disabled: pair = ("未启用", "Disabled")
        case .edit: pair = ("编辑配置", "Edit Profile")
        case .delete: pair = ("删除配置", "Delete Profile")
        case .cancel: pair = ("取消", "Cancel")
        case .save: pair = ("保存配置", "Save Profile")
        case .refresh: pair = ("重新读取", "Reload")
        case .preview: pair = ("确认变更", "Review Changes")
        case .apply: pair = ("授权并应用", "Authorize & Apply")
        case .original: pair = ("变更前的应用配置区", "Managed mappings before")
        case .managed: pair = ("变更后的应用配置区", "Managed mappings after")
        case .notice: pair = ("仅在应用变更时请求管理员授权。关闭应用或卸载此工具不会撤销映射，请先停用配置。", "Changes require administrator authorization. Quitting or uninstalling this tool leaves mappings active; disable profiles first.")
        case .invalidRow: pair = ("请输入有效 IPv4 / IPv6 和域名，不支持通配符、URL 或注释。", "Enter a valid IPv4 / IPv6 address and hostname. Wildcards, URLs and comments are not supported.")
        case .invalidName: pair = ("名称不能为空且不超过 100 字符；说明最多 500 字符。", "Use a name of 1–100 characters and a description of at most 500 characters.")
        case .pending: pair = ("正在等待授权或应用变更…", "Waiting for authorization or applying changes…")
        case .backup: pair = ("每次写入前自动备份。恢复只还原应用配置，保留原有及外部新增内容。", "A backup is saved before every write. Restore affects only managed profiles, preserving external content.")
        case .restore: pair = ("恢复上次配置", "Restore Previous Profiles")
        case .disableAll: pair = ("停用全部", "Disable All")
        case .flush: pair = ("刷新 DNS", "Flush DNS")
        case .flushDone: pair = ("DNS 缓存已刷新", "DNS cache flushed")
        case .confirmation: pair = ("原有 hosts 内容保持不变。确认后将请求系统管理员授权，应用成功后可手动刷新 DNS。", "Existing hosts content stays unchanged. Applying requests administrator authorization. You can flush DNS afterward.")
        case .conflict: pair = ("以下域名有重复映射，可能影响解析，请检查后确认：", "These hostnames have duplicate mappings that may affect resolution. Review before applying:")
        case .failure: pair = ("未能完成操作", "Could Not Complete Operation")
        case .changed: pair = ("hosts 已被其他程序修改。请重新读取并再次预览变更。", "Another program changed hosts. Reload and review the changes again.")
        case .malformed: pair = ("应用标记区不完整或已被外部修改。为保护现有内容，本次未写入，请先检查标记区。", "Managed blocks are incomplete or externally modified. No write was made; inspect the markers first.")
        case .unknown: pair = ("检测到其他安装创建的配置块，本工具不会覆盖。请先用原安装停用配置。", "Managed blocks from another installation were found. Disable them in that installation first.")
        case .storage: pair = ("无法读取或保存配置／备份文件。请检查文件权限和剩余空间。", "Could not read or save profiles or backups. Check permissions and available storage.")
        case .authorization: pair = ("授权已取消或写入未完成。请重新读取后重试；若反复失败，请检查 hosts 权限或残留锁文件。", "Authorization was cancelled or the write failed. Reload and retry; if it persists, check hosts permissions or a stale lock file.")
        case .tooLarge: pair = ("hosts 超过 64 KiB，或包含不支持的内容。为保护文件，已停止操作。", "Hosts exceeds 64 KiB or contains unsupported content. The operation was stopped.")
        case .closeWarning: pair = ("放弃未保存的修改？", "Discard unsaved changes?")
        case .discard: pair = ("放弃修改", "Discard")
        case .count: pair = ("条映射", "mappings")
        case .deleteMessage: pair = ("删除后无法撤销。已启用配置的映射会在授权后移除，原有 hosts 保留。", "Deletion cannot be undone. Enabled mappings are removed after authorization; existing hosts content stays.")
        case .restoreMessage: pair = ("将恢复上次写入前的配置及启用状态，当前原有 hosts 内容不变。", "Restore profiles and their enabled states from before the last write. Current unmanaged hosts content stays unchanged.")
        case .applied: pair = ("配置已应用。如解析结果尚未更新，可点击「刷新 DNS」。", "Profiles applied. Flush DNS if resolution has not updated yet.")
        case .status: pair = ("配置状态", "Profile status")
        case .readOnly: pair = ("现有 hosts 保留 · 所有处理在本机完成", "Existing hosts preserved · Everything stays on this Mac")
        case .search: pair = ("搜索配置名称或域名", "Search profiles or domains")
        }
        switch language {
        case .zhHans: return pair.0
        case .zhTW, .zhHK:
            return pair.0.applyingTransform(StringTransform("Hans-Hant"), reverse: false) ?? pair.0
        default: return pair.1
        }
    }
    func message(_ error: Error) -> String {
        guard let failure = error as? HostsFailure else { return self[.storage] }
        switch failure {
        case .invalid: return self[.invalidRow]
        case .malformed: return self[.malformed]
        case .unknown: return self[.unknown]
        case .changed: return self[.changed]
        case .storage: return self[.storage]
        case .authorization: return self[.authorization]
        case .tooLarge: return self[.tooLarge]
        }
    }
}
