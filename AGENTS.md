# Tandem EMT App

Dual-native mobile app for EMT/Fire response. iOS (Swift/SwiftUI) + Android (Kotlin/Jetpack Compose).

**Every feature must be implemented on BOTH platforms simultaneously.**

## Quick Reference

- Feature specs: `specs/features/`
- Test contracts: `specs/test-contracts/`
- Design tokens: `specs/design/design-language.md`
- iOS theme: `ios/TandemEMT/Core/Theme/AppColors.swift`
- Android theme: `android/app/src/main/java/com/tandem/emt/ui/theme/Color.kt`
- Android tokens: `android/app/src/main/java/com/tandem/emt/ui/theme/DesignTokens.kt`
- Codegen: `tools/codegen/generate.sh`
- CI parity check: `tools/ci/validate-test-parity.sh`

# Cross-Platform Parity — Mandatory Rules

This is a dual-native mobile app (iOS: Swift/SwiftUI, Android: Kotlin/Jetpack Compose).
**Every feature must be implemented on BOTH platforms simultaneously.**

## Before Implementing ANY Feature or Change
- Read the feature spec in `specs/features/` first
- Check both `ios/` and `android/` directories for existing related code
- If modifying an existing feature, read BOTH platform implementations before making changes

## When Implementing a Feature
- Always implement on BOTH platforms in the same session
- Follow the shared test contract in `specs/test-contracts/` for that feature
- Both implementations must pass the same behavioral test cases
- Do NOT submit or consider work "done" if only one platform is implemented

## When Fixing a Bug
- Check if the same bug exists on the other platform
- If the bug is logic-related (not platform-specific rendering), fix it on both platforms
- Document in the PR if a bug is confirmed platform-specific

## When Reviewing or Reading Code
- Always read the equivalent file on the other platform for context
- The parallel file structure makes this straightforward

## Never Do This
- Never implement a feature on only one platform without explicitly stating why
- Never modify a shared spec without updating both platform implementations
- Never add a test on one platform without adding the equivalent test on the other
- Never change a data model on one platform without changing it on the other
- Never skip reading the feature spec before implementing

# Architecture

## Shared Specs (Single Source of Truth)
```
specs/
├── api/              # OpenAPI/protobuf — generates models for both platforms
├── design/           # Design language — colors, icons, typography, spacing
├── features/         # Feature specs define behavior, states, edge cases
└── test-contracts/   # Platform-agnostic test cases both platforms must pass
```

## Platform Code (Mirrored Structure)
Both platforms follow MVVM and mirror each other's file organization:

```
ios/TandemEMT/Features/{FeatureName}/
├── Models/                        # Data models
├── ViewModels/                    # ViewModel + repository
├── Views/                         # SwiftUI views
├── {Feature}Repository.swift      # Repository protocol + impl (feature root)

android/app/src/main/java/com/tandem/emt/features/{featureName}/
├── models/                        # Data models
├── ui/                            # Compose screens/components
├── {Feature}ViewModel.kt          # ViewModel (feature root)
├── {Feature}Repository.kt         # Repository interface + impl (feature root)
```

### Test Locations
```
ios/TandemEMTTests/{Feature}Tests/
└── {Feature}ViewModelTests.swift

ios/TandemEMTUITests/
└── {Feature}UITests.swift

android/app/src/test/java/com/tandem/emt/features/{featureName}/
└── {Feature}ViewModelTest.kt

android/app/src/androidTest/java/com/tandem/emt/features/{featureName}/
└── {Feature}UITest.kt
```

## Naming Conventions
| Concept | iOS (Swift) | Android (Kotlin) |
|---------|-------------|-------------------|
| Feature module | `IncidentList` | `incidentList` |
| ViewModel | `IncidentListViewModel` | `IncidentListViewModel` |
| Main screen | `IncidentListView` | `IncidentListScreen` |
| Model | `Incident` | `Incident` |
| Test class | `IncidentListViewModelTests` | `IncidentListViewModelTest` |

## State Management Pattern
Both platforms model the same state fields, events, and effects — but use platform-idiomatic containers:

### iOS (Swift/SwiftUI)
- State fields as `@Published` properties on `ObservableObject` ViewModel
- Events as `func` methods on the ViewModel (e.g., `func onRefresh()`)
- Effects via `@Published` properties (e.g., `navigationTarget: String?`)

### Android (Kotlin/Compose)
- State as a top-level `data class {Feature}UiState` with `MutableStateFlow`
- Events as `fun` methods on the ViewModel (e.g., `fun onRefresh()`)
- Effects as a `sealed class {Feature}Effect` emitted via `Channel`

### Parity Rule
The **state fields, event methods, and effect cases must be equivalent** across platforms even though the containers differ. Both must have the same:
- State fields (same names, same types, same defaults)
- Public methods for events (same names)
- Effect cases (same cases, same associated data)

# Testing Rules

## Test Contracts
Every feature has a test contract in `specs/test-contracts/{feature-name}.yaml`.
Both platforms MUST implement tests that cover every case in the contract.

## Test Naming — MUST Be Identical Across Platforms
Test function names are **identical** on both platforms. This is non-negotiable.
The contract defines the exact function name and both platforms use it verbatim.

**Format:** `test_{caseId}_{camelCaseDescription}`

```
// Contract defines:  test_name: test_IL001_initialLoadFetchesAndPopulatesState
// iOS:               func test_IL001_initialLoadFetchesAndPopulatesState()
// Android:           fun test_IL001_initialLoadFetchesAndPopulatesState()
```

## Test File Naming
| Test Type | iOS File | Android File |
|-----------|----------|-------------|
| Unit tests (ViewModel) | `{Feature}ViewModelTests.swift` | `{Feature}ViewModelTest.kt` |
| UI tests (Screen) | `{Feature}UITests.swift` | `{Feature}UITest.kt` |

Note: iOS uses plural "Tests", Android uses singular "Test" (platform convention).

## Unit Tests
- Test ViewModel logic, state transitions, data transformations
- Use mock/fake repositories for dependency injection
- Test function names come from the contract `test_name` field

## UI Tests — Cross-Platform Parity
- Every `category: ui` case in a test contract MUST have a UI test on both platforms
- UI test function names MUST be identical on both platforms (from contract `test_name`)
- UI tests should use **test tags / accessibility identifiers** for element lookup, not text matching
- Both platforms MUST use the same test tag names for equivalent elements

## Shared Test Tags (Accessibility Identifiers)
Both platforms must use identical string identifiers. Define these in the test contract under `test_tags`.

**Platform implementation:**
- iOS: `.accessibilityIdentifier("tag_name")`
- Android: `Modifier.testTag("tag_name")`

## UI Test Video Recording
- Run `./tools/ci/record-ui-tests.sh` to record demo videos on both platforms
  - `./tools/ci/record-ui-tests.sh ios` — iOS only
  - `./tools/ci/record-ui-tests.sh android` — Android only (requires running emulator)
  - `./tools/ci/record-ui-tests.sh both` — both platforms
- iOS: Records simulator screen via `xcrun simctl io recordVideo` during test run, saves `.mp4`
- Android: Records emulator screen via `adb shell screenrecord` during test run, saves `.mp4`
- Output: `artifacts/videos/ios/ui-test-recording.mp4` and `artifacts/videos/android/ui-test-recording.mp4`
- Attach these mp4 files to the PR for visual parity review
- Recording is required — do not skip unless the platform toolchain is unavailable

# Design Language Rules

The shared design language is defined in `specs/design/design-language.md`.
This is the single source of truth for visual styling across both platforms.

## Mandatory
- **Always read `specs/design/design-language.md` before implementing any UI**
- Use the defined color tokens — never hardcode hex values in views
- Use the icon mapping table to pick the correct platform-specific icon
- Use the spacing tokens for all padding, margins, and gaps
- Use the component style definitions for cards, badges, chips, banners, etc.

## Adding New Tokens
When adding a new color, icon, or style:
1. Update `specs/design/design-language.md` FIRST
2. Then implement on both platforms:
   - iOS: `ios/TandemEMT/Core/Theme/AppColors.swift`
   - Android: `android/.../ui/theme/Color.kt`
3. Both platform files must contain the exact same hex values from the design language

# Code Generation & Specs

## Code Generation
- Data models are generated from `specs/api/` definitions
- Run `tools/codegen/generate.sh` after modifying any spec in `specs/api/`
- Never hand-edit generated model files — modify the spec and regenerate

## Spec Workflow
- Feature specs in `specs/features/` define behavior, states, and edge cases
- Test contracts in `specs/test-contracts/` define platform-agnostic test cases
- Both must be read BEFORE implementing any feature
- Modifying a spec requires updating both platform implementations

# PR Requirements

- Every feature PR must include changes to BOTH `ios/` and `android/`
- PR must include locally-recorded mp4 video demos from both platforms
  - Run `./tools/ci/record-ui-tests.sh` to generate them
  - Attach `artifacts/videos/ios/ui-test-recording.mp4` and `artifacts/videos/android/ui-test-recording.mp4` to the PR
- If a PR only touches one platform, it must be labeled `platform-specific` with justification
- CI will fail if a feature spec has test contracts that aren't covered on both platforms
