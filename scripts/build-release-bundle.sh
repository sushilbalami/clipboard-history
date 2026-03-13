#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APP_NAME="Clipboard History"
EXECUTABLE_NAME="ClipboardHistoryApp"
BUNDLE_ID="com.clipboard.history"
ARM64_BUILD_DIR="$ROOT_DIR/.build/arm64-apple-macosx/release"
X86_64_BUILD_DIR="$ROOT_DIR/.build/x86_64-apple-macosx/release"
DIST_DIR="$ROOT_DIR/dist"
APP_DIR="$DIST_DIR/$APP_NAME.app"
ZIP_PATH="$DIST_DIR/Clipboard-History-macOS.zip"
ICONSET_SRC="$ROOT_DIR/Sources/ClipboardHistoryApp/Resources/Assets.xcassets/AppIcon.appiconset"
ICONSET_TMP="/tmp/clipboard-history.iconset"
ICON_ICNS_TMP="/tmp/ClipboardHistory.icns"
RESOURCE_BUNDLE="$ARM64_BUILD_DIR/ClipboardHistory_ClipboardHistoryApp.bundle"
UNIVERSAL_BINARY_TMP="$DIST_DIR/$EXECUTABLE_NAME-universal"

echo "Building arm64 release binary..."
swift build --triple arm64-apple-macosx14.0 -c release

echo "Building x86_64 release binary..."
swift build --triple x86_64-apple-macosx14.0 -c release

echo "Creating app bundle..."
rm -rf "$APP_DIR" "$ZIP_PATH" "$UNIVERSAL_BINARY_TMP"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

lipo -create \
  "$ARM64_BUILD_DIR/$EXECUTABLE_NAME" \
  "$X86_64_BUILD_DIR/$EXECUTABLE_NAME" \
  -output "$UNIVERSAL_BINARY_TMP"

cp "$UNIVERSAL_BINARY_TMP" "$APP_DIR/Contents/MacOS/$EXECUTABLE_NAME"
chmod +x "$APP_DIR/Contents/MacOS/$EXECUTABLE_NAME"

if [ -d "$RESOURCE_BUNDLE" ]; then
  cp -R "$RESOURCE_BUNDLE" "$APP_DIR/Contents/Resources/"
fi

rm -rf "$ICONSET_TMP"
mkdir -p "$ICONSET_TMP"
cp "$ICONSET_SRC"/icon_*.png "$ICONSET_TMP"/
iconutil -c icns "$ICONSET_TMP" -o "$ICON_ICNS_TMP"
cp "$ICON_ICNS_TMP" "$APP_DIR/Contents/Resources/AppIcon.icns"

cat > "$APP_DIR/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>$APP_NAME</string>
  <key>CFBundleExecutable</key>
  <string>$EXECUTABLE_NAME</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSAppleEventsUsageDescription</key>
  <string>Clipboard History needs Apple Events access to reactivate the previous app before auto-paste.</string>
  <key>NSHumanReadableCopyright</key>
  <string>Clipboard History</string>
</dict>
</plist>
EOF

codesign --force --deep --sign - "$APP_DIR"

echo "Universal binary architectures:"
lipo -archs "$APP_DIR/Contents/MacOS/$EXECUTABLE_NAME"

echo "Creating release archive..."
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH"

echo "Created:"
echo "  App: $APP_DIR"
echo "  Zip: $ZIP_PATH"
