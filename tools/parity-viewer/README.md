# Parity Viewer

Side-by-side snapshot viewer for comparing iOS and Android visual test snapshots. Browse all snapshot tests in a sidebar and instantly see both platform renderings side by side.

## Quick Start

```bash
cd tools/parity-viewer
npm install
npm start
```

Then open [http://localhost:3474](http://localhost:3474).

## What It Does

- Scans iOS and Android snapshot directories for images
- Matches snapshots across platforms by normalized filename
- Displays a sidebar listing all snapshots with pairing status:
  - **Green dot** — paired (both platforms have a matching snapshot)
  - **Blue dot** — iOS only (missing Android counterpart)
  - **Red dot** — Android only (missing iOS counterpart)
- Split view shows both platform snapshots side by side
- Filter by paired/unpaired status and search by name

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `↑` / `k` | Previous snapshot |
| `↓` / `j` | Next snapshot |
| `/` | Focus search |
| `Esc` | Blur search |

## Snapshot Directories

By default, the viewer looks for snapshots at:

| Platform | Default Path |
|----------|-------------|
| iOS | `ios/TandemEMTTests/__Snapshots__/` |
| Android | `android/app/src/test/snapshots/` |

Override with environment variables:

```bash
IOS_SNAPSHOTS=/path/to/ios/snapshots ANDROID_SNAPSHOTS=/path/to/android/snapshots npm start
```

## Snapshot Matching

Snapshots are matched across platforms by normalizing filenames:

1. Strip file extension
2. Remove platform-specific tokens (`ios`, `android`, `iPhone`, `iPad`, `pixel`, etc.)
3. Remove resolution suffixes (e.g., `_375x812`)
4. Case-insensitive comparison

For best results, name your snapshot tests identically on both platforms (which the test contracts already enforce).

## Port

Default port is `3474`. Override with:

```bash
PORT=8080 npm start
```
