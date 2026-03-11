---
paths:
  - "**/Tests/**"
  - "**/tests/**"
  - "**/*Test*"
  - "specs/test-contracts/**"
---

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
