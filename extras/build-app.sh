#!/bin/bash
# Build "音乐.app": a launcher that starts Music with the TGL VA driver hidden,
# so FairPlay falls back to its software path and streaming works.
set -e
APP="$HOME/Applications/音乐.app"
PROFILE_DIR="$HOME/Library/Application Support/AppleMusicFix"
mkdir -p "$PROFILE_DIR"
cp "$(dirname "$0")/music-novagva.sb" "$PROFILE_DIR/music-novagva.sb"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>CFBundleName</key><string>音乐</string>
  <key>CFBundleDisplayName</key><string>音乐</string>
  <key>CFBundleIdentifier</key><string>local.applemusic.drmfix</string>
  <key>CFBundleVersion</key><string>1.0</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleExecutable</key><string>launch</string>
  <key>CFBundleIconFile</key><string>AppIcon</string>
  <key>LSMinimumSystemVersion</key><string>15.0</string>
  <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST

cat > "$APP/Contents/MacOS/launch" <<'SH'
#!/bin/sh
PROFILE="$HOME/Library/Application Support/AppleMusicFix/music-novagva.sb"
if pgrep -f "/System/Applications/Music.app/Contents/MacOS/Music" >/dev/null 2>&1; then
  exec /usr/bin/osascript -e 'tell application "Music" to activate'
fi
exec /usr/bin/sandbox-exec -f "$PROFILE" /System/Applications/Music.app/Contents/MacOS/Music
SH
chmod +x "$APP/Contents/MacOS/launch"

cp /System/Applications/Music.app/Contents/Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true
touch "$APP"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" 2>/dev/null || true
echo "Built $APP — drag it to the Dock. Quit Music (Cmd-Q) before using it."
