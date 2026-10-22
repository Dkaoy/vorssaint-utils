# 本地整合分支

本目录以新版官方上游为基础，迁入旧 fork 的翻译功能，以及本次开发的 Hosts 配置功能。原目录 `../vorssaint-utils` 与未提交的 Hosts 改动均保留。

## 来源

- 新版上游：`https://github.com/vorssaint/vorssaint-utils.git`
- 上游基点：`02a13224062342f289753733487f6da85db4e332`（Info.plist 版本 3.4.2）
- 翻译来源：`https://github.com/Dkaoy/vorssaint-utils.git`，`d207dc6834aa65e769658f97f0d74e11d022f51a`
- 本地分支：`codex/upstream-with-translation`
- 远程：`upstream` 指向官方仓库，`origin` 指向 `Dkaoy/vorssaint-utils`。发布与更新均使用 origin。

## 保留的功能

- 新版上游自带的 Dynamic Island、布局、内容、活动、行为和小伙伴设置。
- Apple 本地翻译、兼容 Chat Completions 的 AI API、Codex CLI 翻译。
- 手动输入、剪贴板、辅助功能划词和直接框选截图 OCR 翻译。
- 翻译服务和语言记忆、三组快捷键、命令栏入口、API Key 钥匙串隔离。
- Hosts 配置卡片、逐行映射、标记块写入、备份恢复与 DNS 刷新。

旧 fork 的其他专属改动（例如输入法自动切换、蓝牙离开锁定及旧版截图编辑重写）没有整包覆盖新版实现。v3.4.4 及之前的 Dynamic Island 配色沿用上游。从 v3.4.5 起支持自选背景颜色：在「布局 → 背景颜色」启用，支持五组深色预设、系统取色器及恢复默认；浅色自动调暗以保持白色文字可读。启用时使用纯色背景，关闭后恢复原有透明或玻璃选项，设置可随备份导出。实体摄像头刘海仍为黑色。

## 兼容与数据

翻译继续使用原来的 `translation.*` 设置键和 Keychain service 命名方式。同一应用 bundle id 下的设置可继续读取；Developer 版和正式版各有自己的设置域。本次代码迁移未读取或复制真实 API Key、Codex 登录凭据或用户应用数据。

Codex 模型、速度、推理强度可随设置备份导出；CLI 路径属于本机状态，不导出。AI 接口、Key 与模型仍保存在钥匙串，不随设置导出。Hosts 配置文件继续位于对应 bundle id 的 Application Support 目录中，不通过普通设置备份搬运系统映射。

Bob 插件仍被禁用，未将插件 worker 接入应用启动入口。独立测试保留旧兼容层回归，不代表开放插件执行。

本地开发可使用 Developer 构建；正式 fork 已切换到自己的更新源，仅提示手动下载：

```sh
VORSSAINT_ADHOC_SIGNING=1 ./build.sh --dev
```

显式 ad-hoc 模式跳过身份查找、钥匙串解锁和签名身份创建；本次发布不使用 Apple 私钥或公证凭据。当前代码没有创建或更换钥匙串、扩大系统权限、修改真实 hosts 或安装应用。

## 验证命令

```sh
# 仅使用假数据和临时文件；不请求管理员权限或调用真实翻译账户
zsh Tools/test-fork-features.sh

# 上游目录、设置、快捷键及 Dynamic Island 回归
./build.sh --test-suite=features --test-suite=settings --test-suite=keyboard --test-suite=preferences --test-suite=notch --test-suite=feature-hub-layout
```

默认上游测试仍由 `build.sh` 管理。三个独立 @main 测试程序放在 `Tests/Fork/`，避免与上游 `Tests/*.swift` 测试运行器冲突。

## 本次迁移验证结果（2026-10-22）

- 新版全部应用源码以 `VORSSAINT_DEVELOPMENT` 编译为 `build/migration/VorssaintDeveloper`，通过且没有编译警告。这是用于验证的裸可执行文件，不是完成打包的安装版。
- 翻译 80 项、Hosts 68 项、Hosts 服务流程 16 项独立检查全部通过，合计 164 项；没有调用真实翻译账户或写入真实 hosts。
- `features`、`settings`、`keyboard`、`preferences`、`feature-hub-layout` 合计 22,423 项检查全部通过。测试编译仍有上游两处 FileManager / Sendable 警告，没有为本次迁移修改这些测试夹具。
- Dynamic Island 的 66,328 项检查中有 6 项失败：两个窗口附着／关闭检查，以及四个列表选中项可见性检查。在单独导出的、完全未修改的上游 `02a1322` 源码中重新编译运行，同样复现全部 6 项失败。本次迁移未改动 Notch 的布局与行为；发布阶段仅将更新按钮改为手动下载文案。
- `--selftest` 未通过：交换内存与系统启动时间无法读取（系统 `sysctl` 请求在当前沙盒内被拒绝），裸可执行文件缺少菜单栏图片资源，导致一个图标尺寸检查失败。尝试补齐图片的临时验证包也未得到可用的完整运行结果，因此不声称已通过打包应用自检或真实桌面交互验收。
- 初次迁移验证未安装应用、注册后台助手、修改系统 hosts、创建签名身份或推送 GitHub。Apple 模型下载、真实 API / Codex 账户调用，以及真实权限弹窗仍需在正式运行时验证。

检查日志保存在本地 `build/migration/`：`build.log`、`fork-tests-final.log`、`upstream-tests-final.log` 和 `selftest.log`。此前包含未修正测试预期的日志仅供排查，以 `*-final.log` 为收尾结果。

## Fork 发布

当前发布版本为 3.4.5；此前的本机测试版为 3.4.5-beta.1。最低 macOS 14，仅 arm64。发布包为 ad-hoc 签名，未经公证；自动安装入口改为打开对应 GitHub Release 页。原上游签名验证保持严格，受保护的风扇助手不可用于此构建。

```sh
VORSSAINT_ADHOC_SIGNING=1 VORSSAINT_BUILD_JOBS=4 zsh build.sh
zsh Tools/package-fork.sh
```

GitHub Actions 的 Fork Release 支持手动选择已存在的版本标签构建并发布，无需 Apple signing secrets。发布前确保标签指向 main 中的提交，版本与 Info.plist 一致。同名 Release 不会被自动覆盖。Fork CI 执行迁移功能、目录、设置、快捷键与更新测试，并验证 ad-hoc 构建。原上游 CI 和 issue 自动评论工作流仅在官方仓库运行。

## 3.4.3 发布验证补充

- 正式 arm64 应用、受保护助手、Now Playing 动态库均编译通过；助手自检通过。完整应用执行 ad-hoc 签名，`codesign --verify --deep --strict` 通过，未读取或创建 Apple 签名身份。
- 图标生成使用项目内模块缓存，适配受限构建环境；自适应图标 catalog 未能在此环境生成，应用使用完整 AppIcon.icns 回退。
- 翻译 / Hosts 164 项检查再次通过；功能、设置、快捷键、更新等 23,585 项检查在正常桌面上下文全部通过，其中新增四项 fork 更新分发检查。沙盒内更新测试的三个失败（AppleScript / JPEG / 视频类型识别）已在该上下文复验排除。
- 完整应用复制到临时目录并改用随机测试 bundle id，在正常桌面上下文运行 `--selftest` 得到 `SELFTEST OK`。该验证未安装应用，也未迁移或修改用户现有应用偏好。
- Dynamic Island 的 66,328 项检查在正常桌面上下文全部通过；此前沙盒内的六项失败已复验排除。与上述两组回归合计 90,077 项检查全部通过。
- DMG 经 `hdiutil verify` 校验通过；ZIP、应用签名与 SHA-256 清单在发布前校验。安装包未经公证，首次安装需手动下载；受保护风扇控制助手仍不可用于此签名。
- 发布阶段日志位于 `.local-validation/`（已忽略，不提交）；旧迁移日志另存于 `.local-validation/migration/`。

## 3.4.4 发布验证

- 新增 Hosts 完整只读预览、分区切换、行号、统计和重新读取；使用临时文件验证不授权、不写入、异常标记及损坏配置时可查看。
- 翻译 80 项、Hosts 基础 73 项、Hosts 服务流程 24 项检查通过，合计 177 项。以 `.local-validation/v3.4.4-feature-tests-final.log` 为最终结果；首次并行运行被中断后，已在构建结束后单独重跑。
- 全量源码类型检查、中文预览渲染检查、正式 arm64 构建和签名校验通过；自适应图标继续使用 AppIcon.icns 回退。
- 完整应用的临时副本使用随机测试 bundle ID，在正常桌面环境下得到 `SELFTEST OK`；未安装应用或修改系统 hosts。
- 未重新运行 3.4.3 的全部历史测试套件。发布继续使用自己的 GitHub Releases，仅提示手动下载，不启用自动安装。

## 灵动岛配色本地验证

- 新增预设色、自定义取色及恢复默认；实际岛、快捷按钮、布局及内容预览同步。选择纯色时暂时覆盖透明／玻璃显示，原有选择仍保留，关闭自选色后恢复。
- 颜色解析、异常值回退、深色预设精度和白字对比度共 148 项检查通过。
- 灵动岛、设置、默认偏好及功能目录回归共 68,165 项通过；与颜色检查合计 68,313 项。
- 全量源码类型检查与使用随机测试偏好设置域的中文界面渲染通过，未改动真实系统 hosts。
- 先按用户要求在本机安装 3.4.5-beta.1；用户测试后授权提交推送并发布正式版 3.4.5。

## 3.4.5 发布验证

- 正式版版本号 3.4.5、构建号 108，沿用已本地测试的配色实现。
- 发布前翻译 80 项、Hosts 97 项、颜色 148 项检查通过，合计 325 项；正式 arm64 构建、签名校验及临时隔离副本自检通过。
- 本机安装的 3.4.5-beta.1 未被发布打包流程替换；发布仍为未公证安装包，仅手动下载更新。
- 发布日志位于 `.local-validation/v3.4.5-*.log`，不提交本机日志、应用备份或测试偏好设置。
