<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/assets/readme/logo-dark.svg">
    <img src="docs/assets/readme/logo.svg" width="220" alt="Vorssaint 标志">
  </picture>
</p>

<h1 align="center">Vorssaint</h1>

<p align="center">
  一个菜单栏图标，集成多种常用 Mac 工具。<br>
  按需启用，用多少装多少。
</p>

<p align="center">
  <a href="https://vorssaint.com">上游官网</a> ·
  <a href="#安装">安装</a> ·
  <a href="#功能一览">功能</a> ·
  <a href="#隐私保护">隐私</a> ·
  <a href="CHANGELOG.md">更新日志</a> ·
  <a href="mailto:hello@vorssaint.com">联系上游</a> ·
  <a href="https://discord.gg/M6BwWH4BJp">Discord</a>
</p>

<p align="center">
  <a href="https://github.com/Dkaoy/vorssaint-utils/releases"><img src="https://img.shields.io/github/v/release/Dkaoy/vorssaint-utils?label=release&color=4c8dff" alt="最新版本"></a>
  <a href="https://github.com/Dkaoy/vorssaint-utils/releases"><img src="https://img.shields.io/github/downloads/Dkaoy/vorssaint-utils/total?color=4c8dff" alt="下载量"></a>
  <a href="https://github.com/Dkaoy/vorssaint-utils/actions/workflows/ci.yml"><img src="https://github.com/Dkaoy/vorssaint-utils/actions/workflows/ci.yml/badge.svg?branch=main&event=push" alt="持续集成状态"></a>
  <a href="#系统要求"><img src="https://img.shields.io/badge/macOS-14%2B%20Apple%20Silicon-black" alt="macOS 14 及以上，Apple Silicon"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0--or--later-blue" alt="GPL 3.0 或更新版本许可证"></a>
</p>

<p align="center">
  <a href="https://buymeacoffee.com/vorssaint">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" width="217" height="60" alt="请上游作者喝杯咖啡">
  </a>
</p>

<p align="center">
  如需私下联系上游作者，请发送邮件至
  <a href="mailto:hello@vorssaint.com"><strong>hello@vorssaint.com</strong></a>.
</p>

<p align="center">
  <a href="https://trendshift.io/repositories/53716?utm_source=repository-badge&amp;utm_medium=badge&amp;utm_campaign=badge-repository-53716" target="_blank" rel="noopener noreferrer"><img src="https://trendshift.io/api/badge/repositories/53716" alt="vorssaint/vorssaint-utils | Trendshift" width="250" height="55"></a>
  <a href="https://trendshift.io/repositories/53716?utm_source=trendshift-badge&amp;utm_medium=badge&amp;utm_campaign=badge-trendshift-53716" target="_blank" rel="noopener noreferrer"><img src="https://trendshift.io/api/badge/trendshift/repositories/53716/weekly?language=Swift" alt="vorssaint/vorssaint-utils | Trendshift 周榜" width="250" height="55"></a>
  <a href="https://trendshift.io/repositories/53716?utm_source=trendshift-badge&amp;utm_medium=badge&amp;utm_campaign=badge-trendshift-53716" target="_blank" rel="noopener noreferrer"><img src="https://trendshift.io/api/badge/trendshift/repositories/53716/monthly?language=Swift" alt="vorssaint/vorssaint-utils | Trendshift 月榜" width="250" height="55"></a>
</p>

<p align="center">
  <img src="docs/assets/readme/panel-mixer.png" width="196" alt="音量混音器：为各个应用独立调节音量，并可放大至 100% 以上">
  <img src="docs/assets/readme/panel-system.png" width="196" alt="系统监控：温度、使用率曲线和内存压力">
  <img src="docs/assets/readme/panel-controls.png" width="196" alt="窗口控制：应用切换器与 Dock 功能">
  <img src="docs/assets/readme/panel-utilities.png" width="196" alt="实用工具：清理、Homebrew、媒体处理和剪贴板">
</p>

独立应用音量、系统监控、应用切换、窗口吸附、Dock 预览、剪贴板历史、文本片段、文件暂存架、应用卸载……将常用工具集中在一个菜单栏图标中，无需注册账户，没有遥测和订阅。

## 按需启用功能

> **Dkaoy 社区 fork**：新版上游 Dynamic Island + Apple / AI / Codex 翻译 + Hosts 配置。此分支未经 Apple 公证，更新仅提示手动下载。来源、验证与构建说明见 [分支说明](docs/LOCAL-FORK.md)，安装限制见 [发布说明](docs/RELEASE-NOTES.md)。

可以逐项启用功能，也可以从预设开始。卸载某项功能后，它会停止加载并从界面中隐藏；重新安装时会恢复原有设置。应用只会请求所选功能需要的权限。

<p align="center">
  <img src="docs/assets/readme/features-hub.png" width="720" alt="设置中的功能中心，可按需安装或卸载功能">
</p>

支持调整或隐藏面板分区、使用紧凑布局，以及导出设置到其他 Mac。应用支持十余种界面语言。

## 功能一览

### 声音与音频

- **音量混音器。** 为每个应用独立设置音量，将较小的声音放大至 100% 以上，并固定或调整常用应用的顺序，无需安装音频驱动。
- **独立音频输出。** 让音乐通过扬声器播放，同时使用耳机接听通话。
- **输出设备切换。** 通过快捷键切换音频输出，耳机断开后自动降低音量。
- **麦克风工具。** 选择首选输入设备，在支持的设备上调整输入音量，并通过快捷键将所有麦克风静音。
- **阻止音乐应用启动。** 检测播放按键后，阻止系统“音乐”应用意外启动，需要辅助功能权限。

### 系统监控

- **系统监控。** 查看 CPU、GPU、内存、温度、电池健康度和功耗，支持历史曲线与高耗能应用列表。
- **风扇控制（测试版）。** 上游支持手动转速、温度曲线与实时转速监控；本分支的 ad-hoc 签名安装包暂不支持受保护的风扇控制。
- **菜单栏指标。** 将选定的读数、使用率条、电池剩余时间或风扇转速显示在菜单栏中。
- **网络监控。** 查看实时流量、本次会话累计流量和本地 IP 地址，也可运行网络测速。
- **状态提醒。** 在 CPU 持续高负载、温度过高、内存压力过大、磁盘空间不足或电量偏低时接收提醒。

### 窗口与 Dock

- **应用切换器。** 通过实时预览、搜索和显示器筛选切换应用或窗口；简化模式无需录屏权限。
- **窗口布局。** 通过快捷键、屏幕边缘或修饰键拖动，将窗口吸附到指定布局、移动到其他显示器，或恢复之前的位置。
- **Dock 预览。** 悬停在 Dock 图标上，预览不同桌面的窗口，并直接切换、关闭、移动或吸附窗口。
- **Dock 点击行为。** 点击当前应用的 Dock 图标，最小化、隐藏或循环切换其窗口。
- **窗口最大化。** 使用绿色按钮填满屏幕，无需进入新的全屏桌面。
- **固定桌面顺序。** 保持自定的桌面顺序，避免系统根据最近使用情况重新排列；关闭后恢复原有设置。
- **关闭窗口即退出。** 指定应用的最后一个窗口关闭后，自动退出该应用。
- **退出与关闭保护。** 按应用配置长按、双击或附加修饰键确认，避免误触 ⌘Q 或 ⌘W。

<p align="center">
  <img src="docs/assets/readme/quit-protection-hold.png" width="300" alt="长按确认提示，在 Command-Q 退出快捷键下方显示进度">
</p>

<p align="center">
  <img src="docs/assets/readme/window-switcher.gif" width="540" alt="窗口切换器，显示已打开窗口的实时缩略图">
</p>

### 键盘与鼠标

- **文本片段。** 将简短触发词展开为文本，支持剪贴板、日期和时间变量，也可从可搜索菜单中插入片段。
- **平滑滚动。** 让鼠标滚轮滚动更加流畅，可调整速度和响应。
- **鼠标加速度。** 禁用鼠标加速度，关闭功能时恢复原有设置。
- **线性滚动。** 无论滚轮转动多快，每一格都滚动相同的行数。
- **焦点跟随鼠标。** 鼠标停留一段时间后，将指针下方的窗口置于前台，延迟可调整。
- **滚动方向。** 分别反转鼠标的垂直和水平滚动方向，不影响触控板。
- **按键横向滚动。** 按住指定按键时，将滚轮的垂直移动转换为横向滚动。
- **鼠标侧键。** 在访达、浏览器和兼容应用中使用后退与前进按键。
- **鼠标按键快捷操作。** 为额外按键和侧向滚轮分配快捷键，或通过按键拖动手势切换桌面、打开调度中心。
- **中键点击。** 将触控板三指按压转换为鼠标中键点击。
- **应用排除列表。** 对指定应用停用鼠标增强功能。
- **误连击过滤。** 过滤鼠标按键老化导致的快速误连击，不延迟正常点击。
- **键盘去抖。** 过滤键盘老化导致的重复输入。
- **超级键。** 将 Caps Lock 或右侧修饰键映射为快捷键组合，支持单击动作和应用排除列表。
- **快捷键管理。** 集中管理各项功能的快捷键；功能启用时，可选择接管受支持的 macOS 系统快捷键。

### 剪贴板、文件与链接

- **剪贴板历史。** 搜索保存在本机的文本、图片和文件记录，支持固定、预览与快捷键粘贴。
- **自动清空剪贴板。** 在指定延迟、睡眠或锁屏后清空系统剪贴板，同时保留已保存的历史记录。
- **纯文本粘贴。** 粘贴时移除格式，同时保留原始剪贴板内容。
- **文件暂存架。** 拖动时将文件、文本和链接临时存放在指针附近，稍后再拖出或分享。
- **访达快捷操作。** 使用 ⌘X 和 ⌘V 移动文件，使用 F2 重命名，或将复制的图片粘贴为 PNG 文件。
- **链接清理。** 手动或自动移除链接中的跟踪参数。
- **磁盘映像安装器。** 从已挂载的磁盘映像安装应用后弹出映像，并可选择清理下载文件。

### 日常工具

- **翻译。** 支持 Apple 本机翻译、兼容 Chat Completions 的 AI API 和 Codex CLI，提供手动输入、剪贴板、划词及截图 OCR 入口。
- **Hosts 配置。** 使用独立配置卡片管理 IP 与域名映射，启用后追加到自己的 hosts 标记区，保留原有内容；支持变更预览、备份恢复与 DNS 缓存刷新。

- **Dynamic Island（灵动岛）。** 在摄像头刘海附近集中显示音乐、通知、日历、计时器、下载和常用控制；其他 Mac 可使用模拟刘海。支持自定分区和快捷操作，并可启用歌词、实时均衡器、摄像头预览和文件工具。
- **AI 智能体监控。** 在灵动岛中查看 Claude、Codex、OpenCode 和 GitHub Copilot 的状态，包括可获取的套餐额度与重置时间、Token 用量、API 费用估算、模型、项目和实时任务，并在长任务完成时提醒。支持使用 Codex 累积的额度重置机会，以及按 `CODEX_HOME` 为额外账户显示独立额度卡片。Copilot 使用本地 CLI／应用会话日志，收到会话结束指标后更新 Token 总量，汇总费用按基础费率估算。
- **命令栏。** 在统一入口搜索应用、窗口、文件、剪贴板历史、文本片段和应用菜单命令，也可计算、换算单位、查找表情或运行已保存的脚本。
- **快捷面板。** 使用 ⌃⌘V 打开常用工具的悬浮面板。
- **快捷开关。** 快速切换外观、隐藏桌面图标、弹出磁盘、清空废纸篓、锁屏等。
- **环形菜单。** 在指针周围打开可自定的应用、文件、快捷指令和工具菜单，支持配置方案与子菜单。
- **便笺。** 在悬浮窗口或灵动岛中使用自动保存的多标签笔记，支持 Markdown 预览与导出。
- **清洁模式。** 清洁键盘时锁定输入，可使用黑屏或小型状态提示。

### 截图、录屏与创作

- **屏幕采集。** 在带有像素放大镜的统一选区界面中，切换截图、录屏、文字识别和取色。
- **截图。** 截取区域、窗口、屏幕或滚动页面，支持标注、裁剪、遮挡敏感信息、添加背景和水印、固定截图，也可通过系统分享菜单或限时链接分享。
- **录屏。** 分别录制系统声音和麦克风音轨，支持修剪、剪切、自动缩放、模糊敏感信息，导出视频或 GIF，也可生成限时分享链接。
- **摄像头预览。** 通话前，通过悬浮镜像窗口或灵动岛检查摄像头画面。
- **屏幕文字识别。** 离线识别任意屏幕区域中的文字，也可读取二维码。
- **取色器。** 复制屏幕颜色的 HEX、RGB、HSL 值或 SwiftUI 代码。
- **媒体工具。** 在本机压缩和编辑视频、批量转换图片、添加水印、制作 GIF 或提取文字。

### 应用管理

- **应用更新。** 集中检查应用商店、软件包管理器和受支持开发者源中的应用更新，可批量安装可托管的更新，或打开应用自身的更新器。
- **系统清理。** 手动或定时清理缓存、日志和应用残留文件。
- **聊天软件下载管理。** 根据保留规则检查、整理聊天软件的下载文件，或将其移入废纸篓。
- **应用卸载。** 卸载前检查关联的缓存、偏好设置和辅助组件，再将选定内容移入废纸篓。
- **Homebrew 管理。** 无需打开终端，即可搜索、安装和移除 formula 与 cask 软件包。
- **端口管理。** 查找监听网络端口的进程；启用“结束进程”功能后，可直接停止相关进程。

### 电源与显示

- **保持唤醒。** 按计时器、合盖状态、指定应用、电源连接或外接显示器等条件，让 Mac 保持运行。
- **显示器控制。** 独立调整各显示器的亮度，支持的设备可使用硬件控制；亮度键支持半档或四分之一档调节，并可进一步调暗至显示器最低亮度以下，不支持硬件控制时使用软件调暗。
- **额外亮度。** 利用 MacBook Pro XDR 显示屏的 HDR 亮度余量，突破常规最高亮度。
- **睡眠时关闭蓝牙。** 睡眠时断开蓝牙；仅当蓝牙由 Vorssaint 关闭时，才会在唤醒后恢复。

## 安装

从 [Dkaoy 发布页面](https://github.com/Dkaoy/vorssaint-utils/releases)下载本分支的 DMG 或 ZIP，将 Vorssaint 拖入“应用程序”文件夹。

本安装包面向 Apple Silicon，采用 ad-hoc 签名，**未经 Apple 公证**。检测到新版后，会打开本分支的发布页面，由你手动下载和安装。macOS 可能要求在“隐私与安全性”中允许打开；替换应用后，也可能需要重新授予辅助功能或录屏权限。受保护的风扇控制需要可信的 Developer ID 签名，在此构建中不可用。详情见[发布说明](docs/RELEASE-NOTES.md)。

上游的 Homebrew cask 安装的是官方版本，不包含本分支新增的翻译与 Hosts 配置功能。

## 卸载

如果安装的是 Homebrew 官方版本，可运行：

```sh
brew uninstall --cask vorssaint
```

若要完整移除 Vorssaint，包括设置和权限记录，请在源码目录中运行：

```sh
./Tools/uninstall.sh
```

## 隐私保护

Vorssaint 优先在本机处理数据，无需注册 Vorssaint 账户，不包含使用分析或跟踪。联网功能包括更新检查、测速、Homebrew 操作、可选的在线歌词查询、截图或录屏限时分享，以及你主动提交的反馈。本分支的 AI API 和 Codex 翻译还会在你调用时，将待翻译文本发送至所选服务；Apple 翻译使用系统提供的本机翻译能力。详情见[隐私说明](docs/PRIVACY.md)和[翻译说明](docs/TRANSLATION.md)。

系统权限均按需授予。应用会解释每项权限的用途，列出使用它的功能，并在已授权权限不再被任何功能使用时提醒你，提供前往撤销权限的入口。

<p align="center">
  <img src="docs/assets/readme/permissions.png" width="720" alt="权限页面：说明权限用途、使用该权限的功能，并提示不再使用的授权">
</p>

各功能所需权限及未授权时仍可使用的能力，见[权限指南](docs/PERMISSIONS.md)。

## 系统要求

- 搭载 Apple Silicon 芯片的 Mac
- macOS 14 Sonoma 或更新版本

### 自行构建

```sh
git clone https://github.com/Dkaoy/vorssaint-utils.git
cd vorssaint-utils
VORSSAINT_ADHOC_SIGNING=1 ./build.sh --dev  # 构建独立的 Developer 版本

# 构建并打包正式版本，不安装到系统
VORSSAINT_ADHOC_SIGNING=1 ./build.sh
zsh Tools/package-fork.sh
```

构建需要 Xcode Command Line Tools。上述命令显式使用 ad-hoc 签名，不查找 Apple 签名身份，也不创建或解锁应用签名钥匙串。Developer 版本使用独立的应用标识，可与正式版共存。目录结构与约定见[贡献指南](CONTRIBUTING.md)，本分支的验证和发布流程见[分支说明](docs/LOCAL-FORK.md)。

官方构建仅由上游维护者发布，本仓库是社区 fork。源码使用 GPL 许可证；名称、图标和外观的相关说明见 [TRADEMARKS.md](TRADEMARKS.md)。

## 故障排查

启动失败、权限异常或预览缺失等问题，请先查看[故障排查](docs/TROUBLESHOOTING.md)。本分支的问题可提交至 [Dkaoy 仓库的问题页面](https://github.com/Dkaoy/vorssaint-utils/issues)；上游的支持方式见[支持说明](SUPPORT.md)。

## 文档

- [隐私说明](docs/PRIVACY.md)：哪些数据会或不会离开本机
- [权限指南](docs/PERMISSIONS.md)：各项 macOS 权限及其用途
- [故障排查](docs/TROUBLESHOOTING.md)：常见问题与解决方法
- [贡献指南](CONTRIBUTING.md)：构建、目录结构与开发约定
- [支持说明](SUPPORT.md)：上游支持渠道
- [安全说明](SECURITY.md)：漏洞报告方式
- [翻译功能](docs/TRANSLATION.md)：Apple、AI API 与 Codex CLI 翻译
- [Hosts 配置](docs/HOSTS.md)：配置启用、写入预览、备份与恢复
- [分支说明](docs/LOCAL-FORK.md)：迁移来源、兼容性、验证与发布流程

## 社区

上游项目的发展离不开社区的问题反馈与代码贡献。欢迎提交问题报告、功能建议和翻译改进，参与前可先阅读[贡献指南](CONTRIBUTING.md)。上方官网、Discord、联系邮箱、赞助链接和 Trendshift 榜单均属于上游项目。

如果这个项目对你有帮助，欢迎为仓库点亮 Star，也可[请上游作者喝杯咖啡](https://buymeacoffee.com/vorssaint)，支持原项目的开发。

## 致谢

- 应用图标由 [@divisionseven](https://github.com/divisionseven) 设计

## 许可证

源码采用 [GPL 3.0 或更新版本](LICENSE)许可证，版权归 2026 Vorssaint 所有。Vorssaint 名称、标志和外观的单独说明见 [TRADEMARKS.md](TRADEMARKS.md)。

<p align="center">
  <sub>原作者：<a href="https://x.com/vorssaint">@vorssaint</a></sub>
</p>
