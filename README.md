[English](README.md) | [简体中文](README.zh-CN.md)

# StopApp (定时关)

A lightweight native macOS utility that closes selected apps or shuts down your Mac after a countdown.

[![Build macOS app](https://github.com/lichspace/stop-app/actions/workflows/build.yml/badge.svg)](https://github.com/lichspace/stop-app/actions/workflows/build.yml)

## Download and install

Download the latest version from [GitHub Releases](https://github.com/lichspace/stop-app/releases/latest). The installer ZIP includes its version in the filename, for example `StopApp-macOS-0.1.4-unsigned.zip`.

Unzip the download and drag `StopApp.app` into your Applications folder.

Builds are not signed or notarized with an Apple Developer ID. If macOS blocks the first launch, Control-click the app in Finder, choose **Open**, and confirm. You can also review the prompt in **System Settings → Privacy & Security**.

### System requirements

| Requirement | Supported |
| --- | --- |
| macOS | macOS 12 Monterey or later |
| Processor | Apple Silicon or Intel |
| Architecture | Universal binary: `arm64` + `x86_64` |

## Features

- Automatically discovers running desktop apps and refreshes when apps launch or quit.
- Search and select one or more apps by name or bundle ID.
- Quick countdowns: `5 / 10 / 15 / 20 / 25 / 30 / 40 / 50 / 60` minutes.
- Enter a custom number of minutes and see it converted to a readable duration such as “1 hour 25 minutes”.
- See the remaining time and cancel a scheduled action at any time.
- Requests apps to quit normally, then force-quits them after three seconds if needed.
- Schedule a macOS shutdown.
- Native macOS two-column interface with clear hover and selection states.

## Usage

### Schedule apps to close

1. Select **Close apps**.
2. Choose one or more apps from the list. Search by app name or bundle ID if needed.
3. Choose a preset duration or enter a custom number of minutes.
4. Select **Start countdown**.

When the countdown ends, StopApp checks for running apps with the selected bundle IDs, so an app can be relaunched while the timer is running.

### Schedule a shutdown

1. Select **Shut down Mac**.
2. Set the countdown duration.
3. Save your work, then select **Schedule shutdown**.

The first shutdown may prompt macOS to let StopApp control **System Events**.

## Privacy and permissions

- Discovering running apps and requesting that they quit does not require extra permissions.
- Shutdown is requested through macOS **System Events**. Manage its permission under **System Settings → Privacy & Security → Automation**.
- StopApp does not upload your app list, make network requests, or collect usage data.
- Timers run in the app process. Keep StopApp running until the action completes. If your Mac sleeps, an overdue action runs when it wakes.

## Development

### Requirements

- macOS 12 Monterey or later
- Swift 6 toolchain
- Xcode Command Line Tools (the full Xcode app is not required for command-line builds)
- Python 3 only when regenerating the `.icns` app icon

Clone and run:

```bash
git clone https://github.com/lichspace/stop-app.git
cd stop-app
swift run StopApp
```

Run unit tests:

```bash
swift test
```

Build a universal app bundle:

```bash
./scripts/build-app.sh release
open dist/StopApp.app
```

By default, the build includes Apple Silicon and Intel architectures. To build only for the current Mac, set `UNIVERSAL=0`:

```bash
UNIVERSAL=0 ./scripts/build-app.sh release
```

Set the app version and build number:

```bash
APP_VERSION=0.2.0 BUILD_NUMBER=12 ./scripts/build-app.sh release
```

Regenerate the app icon:

```bash
./scripts/make-icns.py Assets/AppIcon-source.png Assets/AppIcon.icns
```

### Project structure

```text
.
├── Assets/                         # App icon source and ICNS
├── Packaging/Info.plist            # App bundle metadata
├── Sources/StopApp/
│   ├── Models/                     # Scheduled actions and duration models
│   ├── Services/                   # App discovery and action execution
│   ├── ViewModels/                 # Timer and view state
│   ├── Views/                      # SwiftUI interface
│   └── StopAppApp.swift            # App entry point
├── Tests/StopAppTests/             # Swift Testing unit tests
├── scripts/build-app.sh            # Universal app packaging
└── scripts/make-icns.py            # App icon generation
```

## Continuous integration and releases

The [GitHub Actions workflow](https://github.com/lichspace/stop-app/actions/workflows/build.yml) does **not** run for ordinary commits or pushes. It runs for version tags and manual test builds.

Stable releases use `vMAJOR.MINOR.PATCH`, for example `v0.1.4`. Push a stable tag to run tests, build the universal app, and publish a GitHub Release with a versioned ZIP such as `StopApp-macOS-0.1.4-unsigned.zip`:

```bash
git tag v0.1.4
git push origin v0.1.4
```

Test builds use `MAJOR.MINOR.PATCH-test.N`, for example `0.1.4-test.1`, then `0.1.4-test.2` for the next iteration. In GitHub, open **Actions → Build macOS app → Run workflow** and enter the test version. A test build runs tests and uploads an artifact, but does not publish a GitHub Release. Its app bundle uses the numeric base version (`0.1.4`), while its artifact name includes the full test version.

## Contributing

Before opening a pull request, run:

```bash
swift test
./scripts/build-app.sh release
```

Please update or add tests when changing behavior. For UI changes, check both light and dark appearances and verify that content fits at the minimum window size.

## FAQ

### An app is missing from the list

The list includes apps with regular desktop windows. Select the refresh button; the list also refreshes when apps launch or quit.

### A shutdown action does not run

Check StopApp’s **System Events** permission under **System Settings → Privacy & Security → Automation**, then schedule the action again.

### Does the timer continue after closing the window?

Yes, while StopApp remains running. Quitting with `Command-Q` stops any pending action.
