# Clipboard History

Clipboard History is a native macOS menu bar app that keeps a searchable history of copied text and lets you bring it back with a global shortcut.

It is built with Swift, SwiftUI, and AppKit, packaged as `Clipboard History.app`, and distributed through GitHub Releases.

## Features

- Global shortcut to open clipboard history from anywhere
- Searchable list of recent clipboard items
- Pin, copy, and delete actions
- Optional auto-paste flow after selection
- Launch at login
- Menu bar utility with floating history panel
- Native macOS app bundle packaging

## Download

The latest build is published automatically from `main`:

- Latest release page: [GitHub Releases](https://github.com/sushilbalami/clipboard-history/releases/latest)
- Direct download: [Clipboard-History-macOS.zip](https://github.com/sushilbalami/clipboard-history/releases/latest/download/Clipboard-History-macOS.zip)

## Install on macOS

1. Download the latest release ZIP.
2. Extract `Clipboard History.app`.
3. Move it to `/Applications`.
4. Launch the app.
5. If you want auto-paste, enable it in:
   `System Settings -> Privacy & Security -> Accessibility`

If macOS still reports missing permission after enabling Accessibility, quit the app and launch it again once. TCC propagation can lag.

## Build from Source

Requirements:

- macOS 14 or later
- Xcode / Swift toolchain available

Build and install locally:

```bash
./scripts/install-app.sh
```

This script:

- builds a release binary
- creates `Clipboard History.app`
- installs it to `/Applications`

Build a release bundle without installing:

```bash
./scripts/build-release-bundle.sh
```

That produces:

- `dist/Clipboard History.app`
- `dist/Clipboard-History-macOS.zip`

## Development

Run tests:

```bash
swift test
```

Open the package in Xcode:

```bash
open Package.swift
```

Project structure:

- [Sources/ClipboardHistoryApp](/Users/sushil_balami/Documents/Projects/Personal%20Projects/clipboard-history/Sources/ClipboardHistoryApp)
- [Tests/ClipboardHistoryAppTests](/Users/sushil_balami/Documents/Projects/Personal%20Projects/clipboard-history/Tests/ClipboardHistoryAppTests)
- [web](/Users/sushil_balami/Documents/Projects/Personal%20Projects/clipboard-history/web)
- [scripts](/Users/sushil_balami/Documents/Projects/Personal%20Projects/clipboard-history/scripts)

## Permissions

Clipboard capture itself does not require Accessibility.

Auto-paste does require Accessibility because the app re-focuses the previous app and simulates the paste shortcut.

If you need to reset Accessibility permissions during local testing:

```bash
tccutil reset Accessibility
```

Then re-add:

- `/Applications/Clipboard History.app`

## Release Automation

GitHub Actions builds and publishes a release whenever code is pushed to `main`.

Workflow:

- [release-macos.yml](/Users/sushil_balami/Documents/Projects/Personal%20Projects/clipboard-history/.github/workflows/release-macos.yml)

Release pipeline behavior:

1. Builds the macOS app bundle on GitHub-hosted macOS runners
2. Packages the app as `Clipboard-History-macOS.zip`
3. Creates a GitHub Release
4. Marks the newest release as the latest release
