#!/bin/zsh
# SPDX-License-Identifier: GPL-3.0-or-later
# Package without mounting volumes, changing installed apps or accessing keys.
set -euo pipefail
cd "$(dirname "$0")/.."
APP="build/stage/Vorssaint.app"
[[ -d "$APP" ]] || { echo "Run VORSSAINT_ADHOC_SIGNING=1 zsh build.sh first" >&2; exit 1; }
codesign --verify --deep --strict "$APP"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$APP/Contents/Info.plist")"
[[ "$VERSION" == "$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' Resources/Info.plist)" ]]
mkdir -p dist
ARCHIVE="dist/Vorssaint-$VERSION-arm64.zip"
IMAGE="dist/Vorssaint-$VERSION-arm64.dmg"
[[ ! -e "$ARCHIVE" && ! -e "$IMAGE" ]] || { echo "Release artifacts already exist; refusing to overwrite" >&2; exit 1; }
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT
ditto --noextattr --noqtn "$APP" "$STAGING/Vorssaint.app"
ln -s /Applications "$STAGING/Applications"
cp docs/RELEASE-NOTES.md "$STAGING/INSTALL.md"
codesign --verify --deep --strict "$STAGING/Vorssaint.app"
ditto -c -k --sequesterRsrc --keepParent "$STAGING/Vorssaint.app" "$ARCHIVE"
hdiutil create -volname "Vorssaint $VERSION" -srcfolder "$STAGING" -fs HFS+ -format UDZO "$IMAGE"
hdiutil verify "$IMAGE"
(cd dist && shasum -a 256 "Vorssaint-$VERSION-arm64.dmg" "Vorssaint-$VERSION-arm64.zip" > SHA256SUMS && shasum -a 256 -c SHA256SUMS)
