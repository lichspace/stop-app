[English](README.md) | [简体中文](README.zh-CN.md)

# 定时关（StopApp）

一款轻量、原生的 macOS 定时工具，可在倒计时结束后关闭所选应用或关闭电脑。

[![macOS 构建](https://github.com/lichspace/stop-app/actions/workflows/build.yml/badge.svg)](https://github.com/lichspace/stop-app/actions/workflows/build.yml)

## 下载与安装

前往 [GitHub Releases](https://github.com/lichspace/stop-app/releases/latest) 下载最新版本。安装包文件名包含版本号，例如 `StopApp-macOS-0.1.4-unsigned.zip`。

解压后，将 `StopApp.app` 拖入“应用程序”文件夹。

构建版本尚未使用 Apple Developer ID 签名或公证。首次打开若 macOS 阻止运行，请在 Finder 中按住 Control 键并点按应用，选择“打开”后确认；也可以在“系统设置 → 隐私与安全性”中查看提示。

### 系统要求

| 项目 | 要求 |
| --- | --- |
| macOS | macOS 12 Monterey 或更高版本 |
| 处理器 | Apple Silicon 或 Intel Mac |
| 架构 | 通用二进制：`arm64` + `x86_64` |

## 功能

- 自动发现正在运行的桌面应用，并在应用启动或退出时刷新列表。
- 可按名称或 Bundle ID 搜索应用，并选择一个或多个应用。
- 提供 `5 / 10 / 15 / 20 / 25 / 30 / 40 / 50 / 60` 分钟快捷选项。
- 支持手动输入分钟数，并换算成“1小时25分钟”等可读时长。
- 实时显示剩余时间，可随时取消计划任务。
- 优先请求应用正常退出；3 秒后仍未退出时再强制结束。
- 支持定时关闭 macOS。
- 原生 macOS 双栏界面，并提供清晰的悬停和选中状态。

## 使用方法

### 定时关闭应用

1. 选择“关闭应用”。
2. 从列表中选择一个或多个应用；也可以按名称或 Bundle ID 搜索。
3. 选择快捷时长，或手动输入分钟数。
4. 选择“开始计时”。

计时结束时，StopApp 会按所选 Bundle ID 检查正在运行的应用，因此计时期间重新启动的应用也能被识别。

### 定时关机

1. 选择“关闭电脑”。
2. 设置倒计时时长。
3. 保存其他应用中的工作，然后选择“安排关机”。

首次执行关机任务时，macOS 可能会询问是否允许 StopApp 控制“系统事件”。

## 隐私与权限

- 发现正在运行的应用以及请求应用退出，不需要额外权限。
- 关机功能通过 macOS“系统事件”发起。可在“系统设置 → 隐私与安全性 → 自动化”中管理权限。
- StopApp 不上传应用列表、不发起网络请求，也不收集使用数据。
- 定时器运行在应用进程内；任务完成前请保持 StopApp 运行。电脑从睡眠状态恢复后，已到期的任务会立即执行。

## 开发

### 环境要求

- macOS 12 Monterey 或更高版本
- Swift 6 工具链
- Xcode Command Line Tools（命令行构建不要求安装完整 Xcode）
- 仅在重新生成 `.icns` 应用图标时需要 Python 3

克隆并运行：

```bash
git clone https://github.com/lichspace/stop-app.git
cd stop-app
swift run StopApp
```

运行单元测试：

```bash
swift test
```

构建通用应用：

```bash
./scripts/build-app.sh release
open dist/StopApp.app
```

默认同时构建 Apple Silicon 与 Intel 架构。只构建当前 Mac 的架构时，设置 `UNIVERSAL=0`：

```bash
UNIVERSAL=0 ./scripts/build-app.sh release
```

设置应用版本号和构建号：

```bash
APP_VERSION=0.2.0 BUILD_NUMBER=12 ./scripts/build-app.sh release
```

重新生成应用图标：

```bash
./scripts/make-icns.py Assets/AppIcon-source.png Assets/AppIcon.icns
```

### 项目结构

```text
.
├── Assets/                         # 图标源文件和 ICNS
├── Packaging/Info.plist            # 应用包元数据
├── Sources/StopApp/
│   ├── Models/                     # 定时任务和时长模型
│   ├── Services/                   # 应用发现与任务执行
│   ├── ViewModels/                 # 计时器和界面状态
│   ├── Views/                      # SwiftUI 界面
│   └── StopAppApp.swift            # 应用入口
├── Tests/StopAppTests/             # Swift Testing 单元测试
├── scripts/build-app.sh            # 通用应用打包脚本
└── scripts/make-icns.py            # 应用图标生成脚本
```

## 持续集成与版本发布

[GitHub Actions 工作流](https://github.com/lichspace/stop-app/actions/workflows/build.yml)不会因普通提交或推送而运行，只会在推送版本标签或手动触发测试构建时运行。

正式版使用 `v主版本.次版本.修订号` 格式，例如 `v0.1.4`。推送正式版标签后，工作流会运行测试、构建通用应用并创建 GitHub Release，安装包名称包含版本号，例如 `StopApp-macOS-0.1.4-unsigned.zip`：

```bash
git tag v0.1.4
git push origin v0.1.4
```

测试版使用 `主版本.次版本.修订号-test.序号` 格式，例如 `0.1.4-test.1`；下一轮测试递增为 `0.1.4-test.2`。在 GitHub 中打开 **Actions → Build macOS app → Run workflow** 并填写测试版本号。测试构建会运行测试并上传构建产物，但不会发布 GitHub Release。应用包内的版本号使用数字基础版本（如 `0.1.4`），Artifact 名称则保留完整测试版本号。

## 参与开发

提交 Pull Request 前请运行：

```bash
swift test
./scripts/build-app.sh release
```

修改功能时请同步补充或更新测试。修改界面后建议检查浅色和深色模式，并确认窗口最小尺寸下内容没有溢出。

## 常见问题

### 应用没有出现在列表中

列表只显示带普通桌面窗口的应用。点击刷新按钮；应用启动或退出时列表也会自动刷新。

### 关机任务没有执行

在“系统设置 → 隐私与安全性 → 自动化”中检查 StopApp 对“系统事件”的权限，然后重新安排任务。

### 关闭窗口后计时还会继续吗？

会，只要 StopApp 仍在运行。按 `Command-Q` 完全退出应用会停止尚未执行的任务。
