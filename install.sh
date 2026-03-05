#!/bin/bash
set -e

echo "Building SSHDashboard..."
swift build -c release 2>&1 | tail -1

APP_DIR="$HOME/Applications/SSHDashboard.app/Contents/MacOS"
PLIST_DIR="$HOME/Applications/SSHDashboard.app/Contents"

mkdir -p "$APP_DIR"

cp .build/release/SSHDashboard "$APP_DIR/SSHDashboard"
cp SSHDashboard/Info.plist "$PLIST_DIR/Info.plist"

echo "Installed to ~/Applications/SSHDashboard.app"

# Add as login item so it launches on startup
osascript -e 'tell application "System Events" to make login item at end with properties {path:"'$HOME'/Applications/SSHDashboard.app", hidden:true}' 2>/dev/null || true

echo ""
echo "SSHDashboard will now launch automatically on login."
echo "To launch now: open ~/Applications/SSHDashboard.app"
