#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
PROJECT_DIR="${SCRIPT_DIR:h}"
CONFIGURATION="${1:-release}"
APP_VERSION="${APP_VERSION:-0.1.0}"
BUILD_NUMBER="${BUILD_NUMBER:-1}"
UNIVERSAL="${UNIVERSAL:-1}"
APP_DIR="$PROJECT_DIR/dist/StopApp.app"
CONTENTS_DIR="$APP_DIR/Contents"

mkdir -p "$CONTENTS_DIR/MacOS" "$CONTENTS_DIR/Resources"

if [[ "$UNIVERSAL" == "1" ]]; then
    ARM_SCRATCH="$PROJECT_DIR/.build/arm64"
    INTEL_SCRATCH="$PROJECT_DIR/.build/x86_64"

    (cd "$PROJECT_DIR" && swift build -c "$CONFIGURATION" --triple arm64-apple-macosx12.0 --scratch-path "$ARM_SCRATCH" --product StopApp)
    (cd "$PROJECT_DIR" && swift build -c "$CONFIGURATION" --triple x86_64-apple-macosx12.0 --scratch-path "$INTEL_SCRATCH" --product StopApp)

    ARM_BIN_DIR="$(cd "$PROJECT_DIR" && swift build -c "$CONFIGURATION" --triple arm64-apple-macosx12.0 --scratch-path "$ARM_SCRATCH" --show-bin-path)"
    INTEL_BIN_DIR="$(cd "$PROJECT_DIR" && swift build -c "$CONFIGURATION" --triple x86_64-apple-macosx12.0 --scratch-path "$INTEL_SCRATCH" --show-bin-path)"

    /usr/bin/lipo -create \
        "$ARM_BIN_DIR/StopApp" \
        "$INTEL_BIN_DIR/StopApp" \
        -output "$CONTENTS_DIR/MacOS/StopApp"
else
    (cd "$PROJECT_DIR" && swift build -c "$CONFIGURATION" --product StopApp)
    BIN_DIR="$(cd "$PROJECT_DIR" && swift build -c "$CONFIGURATION" --show-bin-path)"
    cp -f "$BIN_DIR/StopApp" "$CONTENTS_DIR/MacOS/StopApp"
fi

cp -f "$PROJECT_DIR/Packaging/Info.plist" "$CONTENTS_DIR/Info.plist"
cp -f "$PROJECT_DIR/Assets/AppIcon.icns" "$CONTENTS_DIR/Resources/AppIcon.icns"
chmod +x "$CONTENTS_DIR/MacOS/StopApp"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $APP_VERSION" "$CONTENTS_DIR/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NUMBER" "$CONTENTS_DIR/Info.plist"

echo "Built $APP_DIR (version $APP_VERSION, build $BUILD_NUMBER)"
