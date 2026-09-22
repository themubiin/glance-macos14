#!/bin/bash
set -euo pipefail

echo "==> Checking build environment..."
if ! command -v xcodebuild >/dev/null 2>&1; then
    echo "Error: xcodebuild is not available. Please install Xcode and run: sudo xcode-select -s /Applications/Xcode.app"
    exit 1
fi

BUILD_DIR="${PWD}/build"
RELEASE_DIR="${BUILD_DIR}/Release"
APP_PATH="${RELEASE_DIR}/Glance.app"
DMG_PATH="${PWD}/Glance-macOS14-Universal.dmg"

echo "==> Building Glance for macOS 14+ (arm64 & x86_64)..."
xcodebuild -project glance.xcodeproj \
    -scheme glance \
    -configuration Release \
    -destination "generic/platform=macOS" \
    ARCHS="arm64 x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO \
    CONFIGURATION_BUILD_DIR="${RELEASE_DIR}" \
    clean build

echo "==> Packaging DMG..."
DMG_ROOT=$(mktemp -d /tmp/glance-dmg.XXXXXX)
cp -R "${APP_PATH}" "${DMG_ROOT}/"
ln -s /Applications "${DMG_ROOT}/Applications"
hdiutil create -volname "Glance" -srcfolder "${DMG_ROOT}" -ov -format UDZO "${DMG_PATH}"
rm -rf "${DMG_ROOT}"

echo "==> Build complete: ${DMG_PATH}"
