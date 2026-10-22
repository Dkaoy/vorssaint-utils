## Vorssaint 3.4.3 · Dkaoy fork

基于官方 3.4.2，保留新版 Dynamic Island，并整合 Apple / AI API / Codex CLI 翻译与 Hosts 配置管理。

- Hosts 使用带样式的独立配置、逐行域名映射和启用开关；仅管理自己的标记块，应用前预览并备份，不覆盖原有 hosts 内容。
- 更新源为 Dkaoy/vorssaint-utils 的 GitHub Releases；发现新版后打开发布页，下载并手动安装，不运行自动安装程序。
- 支持 Apple Silicon（arm64），macOS 14 或更新系统。

### 安装

这是 ad-hoc 签名、**未经 Apple 公证**的社区 fork，不是官方签名版本。打开 DMG，将 Vorssaint 拖入 Applications；也可解压 ZIP 后拖入 Applications。若系统阻止打开，请在系统设置 → 隐私与安全性中确认来源后选择“仍要打开”。没有系统级关闭 Gatekeeper 的步骤。

由于没有稳定 Developer ID 签名，每次更换二进制后可能需要重新授予辅助功能和录屏权限。受保护的风扇控制助手仍校验原有可信签名，在本构建中不可用；没有放宽其身份校验。Dynamic Island 配色仍沿用上游。

### 验证及已知限制

翻译 / Hosts 的 164 项检查和功能、设置、快捷键、更新等 23,585 项检查通过。完整应用的临时隔离副本在正常桌面环境下自检通过（SELFTEST OK）；应用、助手和媒体适配器编译及 ad-hoc 签名校验通过。沙盒中的 AppleScript、文件类型识别和系统指标读取限制已通过桌面环境复验排除。

Dynamic Island 在正常桌面环境下复验，66,328 项检查全部通过；此前沙盒环境中的六项失败也在未修改的上游复现。以上回归合计 90,077 项全部通过。真实账户翻译、系统权限与完整桌面交互仍需安装后验证。未使用真实账户测试，也未修改开发机器 hosts。

源代码与上游许可按 GPL-3.0-or-later 提供，见仓库 LICENSE。
