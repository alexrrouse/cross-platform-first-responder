# POC FOR DEMO PURPOSES ONLY


# Tandem EMT

Dual-native mobile app for EMT/Fire response. iOS (Swift/SwiftUI) and Android (Kotlin/Jetpack Compose) developed simultaneously with automated parity enforcement at every layer.

This is not a cross-platform framework — both platforms are fully native. Shared specs, test contracts, and CI tooling ensure the two apps stay in lockstep.

## Architecture

Both platforms follow **MVVM** with an identical **State / Event / Effect** pattern. File structure is mirrored:

```
ios/TandemEMT/Features/{FeatureName}/       android/…/features/{featureName}/
├── Models/                                 ├── models/
├── ViewModels/                             ├── ui/
├── Views/                                  ├── {Feature}ViewModel.kt
└── {Feature}Repository.swift               └── {Feature}Repository.kt
```

State fields, event methods, and effect cases are equivalent across platforms — same names, same types, same defaults.

## Spec-Driven Development

A single source of truth lives in `specs/` and drives both implementations:

```
specs/
├── features/          # Feature specs — behavior, states, edge cases
├── test-contracts/    # YAML test contracts both platforms must pass
└── design/            # Design language — colors, icons, typography, spacing
```

**Workflow:** write the feature spec → define the test contract → implement on both platforms → CI validates parity.

### Test Contracts

Each feature has a YAML contract that defines every test case both platforms must implement by exact function name:

```yaml
cases:
  - id: IL001
    test_name: test_IL001_initialLoadFetchesAndPopulatesState
    category: unit
    given: "ViewModel is initialized"
    when: "onScreenAppear is called"
    then: "incidents list is populated from API response"
```

Both platforms must have a test function matching `test_name` exactly. Shared `test_tags` (e.g., `loading_indicator`, `error_state`) are used as accessibility identifiers on iOS and test tags on Android so UI tests target the same elements.

### Design Language

`specs/design/design-language.md` defines colors, icons (mapped between SF Symbols and Material Icons), typography, spacing (4pt grid), and component styles. Both platforms pull from the same token definitions.

## Parity Checks

### 1. Test Parity Validator

`tools/ci/validate-test-parity.sh` — reads every YAML test contract, extracts `test_name` values, and scans both iOS and Android test directories to confirm each function exists. Blocks the PR if any platform is missing a test case.

### 2. UI Test Video Recording

`tools/ci/record-ui-tests.sh` — runs UI tests on both platforms with video capture enabled:

- **iOS:** `xcodebuild test` with result bundles, videos extracted from `.xcresult`
- **Android:** Gradle Managed Device (Pixel 6, API 34) with test reports

Videos are uploaded as CI artifacts and linked in a PR comment for visual side-by-side review.

### 3. Parity Viewer

`tools/parity-viewer/` — local web tool for browsing snapshot tests side by side. Scans iOS and Android snapshot directories, matches images by normalized filename, and displays them in a split view with pairing status indicators.

```bash
cd tools/parity-viewer && npm install && npm start
# http://localhost:3474
```

## CI Pipeline

Every PR runs through four stages in `.github/workflows/pr-checks.yaml`:

| Stage | Runner | What It Does |
|-------|--------|-------------|
| **Test Parity** | Ubuntu | Validates all test contracts are covered on both platforms. Gates everything else. |
| **iOS Tests** | macOS | Unit tests + UI tests with video recording. Uploads `.xcresult` bundles. |
| **Android Tests** | Ubuntu | Unit tests + Gradle Managed Device UI tests. Uploads test reports. |
| **Post Videos** | Ubuntu | Comments on the PR with links to video artifacts from both platforms. |

## Project Structure

```
├── ios/                    # iOS app (Swift/SwiftUI)
├── android/                # Android app (Kotlin/Jetpack Compose)
├── specs/
│   ├── features/           # Feature specifications
│   ├── test-contracts/     # Behavioral test contracts (YAML)
│   └── design/             # Design language tokens
├── tools/
│   ├── ci/                 # Test parity validator, UI test recorder
│   └── parity-viewer/      # Snapshot comparison viewer
├── .github/workflows/      # CI pipeline
└── .claude/rules/          # Development conventions
```

## Getting Started

**iOS** — open `ios/TandemEMT.xcodeproj` in Xcode, build and run on a simulator.

**Android** — open the `android/` directory in Android Studio, sync Gradle, and run on an emulator.

**Parity Viewer** — `cd tools/parity-viewer && npm install && npm start`
