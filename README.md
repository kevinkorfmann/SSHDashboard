# SSH Dashboard for macOS

A lightweight macOS menu bar app and desktop widget that displays your SSH hosts from `~/.ssh/config`. Click a host to open a Terminal session.

## Features

- **Desktop widget** — a translucent, draggable widget showing all your SSH hosts, styled like a native macOS widget
- **Menu bar icon** — quick access to SSH hosts from the menu bar
- **One-click connect** — click any host to open an SSH session in Terminal
- **Auto-refresh** — refresh your host list when your SSH config changes
- **Login item** — starts automatically on boot

## Requirements

- macOS 13+
- Swift 5.9+

## Install

```sh
./install.sh
```

This will:
1. Build a release binary
2. Install it to `~/Applications/SSHDashboard.app`
3. Register it as a login item (launches on startup)

To launch immediately:

```sh
open ~/Applications/SSHDashboard.app
```

## Development

Build and run locally:

```sh
swift build
.build/debug/SSHDashboard
```

## Uninstall

```sh
rm -rf ~/Applications/SSHDashboard.app
osascript -e 'tell application "System Events" to delete login item "SSHDashboard"'
```

Or remove it manually from **System Settings > General > Login Items**.
