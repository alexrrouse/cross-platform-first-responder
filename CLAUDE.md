# Tandem EMT App — AI Development Rules

## Critical: Cross-Platform Parity

This is a dual-native mobile app (iOS: Swift/SwiftUI, Android: Kotlin/Jetpack Compose).
**Every feature must be implemented on BOTH platforms simultaneously.**

### Mandatory Cross-Platform Workflow

1. **Before implementing ANY feature or change:**
   - Read the feature spec in `specs/features/` first
   - Check both `ios/` and `android/` directories for existing related code
   - If modifying an existing feature, read BOTH platform implementations before making changes

2. **When implementing a feature:**
   - Always implement on BOTH platforms in the same session
   - Follow the shared test contract in `specs/test-contracts/` for that feature
   - Both implementations must pass the same behavioral test cases
   - Do NOT submit or consider work "done" if only one platform is implemented

3. **When fixing a bug:**
   - Check if the same bug exists on the other platform
   - If the bug is logic-related (not platform-specific rendering), fix it on both platforms
   - Document in the PR if a bug is confirmed platform-specific

4. **When reviewing or reading code:**
   - Always read the equivalent file on the other platform for context
   - The parallel file structure makes this straightforward (see Architecture section)

### Never Do This
- Never implement a feature on only one platform without explicitly stating why
- Never modify a shared spec without updating both platform implementations
- Never add a test on one platform without adding the equivalent test on the other
- Never change a data model on one platform without changing it on the other
- Never skip reading the feature spec before implementing
- Never hardcode colors — always use tokens from `specs/design/design-language.md`
- Never pick an icon without checking the icon mapping table in the design language

## Architecture

### Shared Specs (Single Source of Truth)
```
specs/
├── api/              # OpenAPI/protobuf — generates models for both platforms
├── design/           # Design language — colors, icons, typography, spacing
├── features/         # Feature specs define behavior, states, edge cases
└── test-contracts/   # Platform-agnostic test cases both platforms must pass
```

### Platform Code (Mirrored Structure)
Both platforms follow MVVM and mirror each other's file organization:

```
ios/Features/{FeatureName}/
├── Models/           # Data models (generated from specs/api where possible)
├── ViewModels/       # Business logic, state management
├── Views/            # SwiftUI views
└── Tests/            # Unit + UI tests matching specs/test-contracts

android/features/{featureName}/
├── models/           # Data models (generated from specs/api where possible)
├── viewmodels/       # Business logic, state management
├── ui/               # Compose screens/components
└── tests/            # Unit + UI tests matching specs/test-contracts
```

### Naming Conventions
| Concept | iOS (Swift) | Android (Kotlin) |
|---------|-------------|-------------------|
| Feature module | `IncidentList` | `incidentList` |
| ViewModel | `IncidentListViewModel` | `IncidentListViewModel` |
| Main screen | `IncidentListView` | `IncidentListScreen` |
| Model | `Incident` | `Incident` |
| Test class | `IncidentListViewModelTests` | `IncidentListViewModelTest` |

### State Management Pattern
Both platforms use the same state machine approach:
- **State**: A single immutable state object per screen/feature
- **Events/Actions**: User interactions that trigger state changes
- **Effects/Side Effects**: One-shot events (navigation, toasts, etc.)

```
// Both platforms model state identically:
State {
  isLoading: Boolean
  items: List<Item>
  error: String?
}

Event {
  OnLoad
  OnRefresh
  OnItemTapped(id)
}

Effect {
  NavigateToDetail(id)
  ShowError(message)
}
```

## Testing Rules

### Test Contracts
Every feature has a test contract in `specs/test-contracts/{feature-name}.yaml`.
Both platforms MUST implement tests that cover every case in the contract.

### Test Naming — MUST Be Identical Across Platforms
Test function names are **identical** on both platforms. This is non-negotiable.
The contract defines the exact function name and both platforms use it verbatim.

```
// Contract defines:
//   test_name: test_IL001_initialLoadFetchesAndPopulatesState
//
// iOS:
//   func test_IL001_initialLoadFetchesAndPopulatesState()
//
// Android:
//   fun test_IL001_initialLoadFetchesAndPopulatesState()
```

**Format:** `test_{caseId}_{camelCaseDescription}`

This ensures:
- The parity checker can verify both platforms implement every case
- Test results from both platforms can be compared side-by-side by name
- Video recordings from UI tests can be matched 1:1 between platforms

### Test File Naming — MUST Be Identical Across Platforms
Test files follow the same naming convention on both platforms:

| Test Type | iOS File | Android File |
|-----------|----------|-------------|
| Unit tests (ViewModel) | `{Feature}ViewModelTests.swift` | `{Feature}ViewModelTest.kt` |
| UI tests (Screen) | `{Feature}UITests.swift` | `{Feature}UITest.kt` |

Note: iOS uses plural "Tests", Android uses singular "Test" (platform convention).

### Unit Tests
- Test ViewModel logic, state transitions, data transformations
- Use mock/fake repositories for dependency injection
- Test function names come from the contract `test_name` field

### UI Tests — Cross-Platform Parity
UI tests verify visual rendering and user interactions. They are critical for
ensuring both platforms look and behave the same.

**Rules:**
- Every `category: ui` case in a test contract MUST have a UI test on both platforms
- UI test function names MUST be identical on both platforms (from contract `test_name`)
- UI tests should use **test tags / accessibility identifiers** for element lookup,
  not text matching (text may differ slightly between platforms)
- Both platforms MUST use the same test tag names for equivalent elements

**Shared Test Tags (accessibility identifiers):**
Both platforms must use identical string identifiers for testable elements.
Define these in the test contract under `test_tags`.

```yaml
# Example from test contract:
test_tags:
  - empty_state          # Empty state container
  - error_state          # Error state container
  - retry_button         # Retry button in error state
  - loading_indicator    # Loading spinner/skeleton
  - filter_chip_{NAME}   # Filter chip (e.g., filter_chip_ALL)
  - incident_card_{id}   # Incident card by ID
  - case_number          # Case number text in card
  - address              # Address text in card
  - status_badge         # Status badge in card
  - dispatch_time        # Dispatch time text in card
  - unit_count           # Unit count text in card
  - offline_banner       # Offline banner
```

**Platform implementation of test tags:**
- iOS: Use `.accessibilityIdentifier("tag_name")`
- Android: Use `Modifier.testTag("tag_name")`

### UI Test Video Recording
- UI tests record screen videos during CI runs
- iOS: Xcode test recordings via `xcodebuild test` with `-resultBundlePath`
- Android: Gradle managed device recordings or `adb screenrecord`
- Videos are uploaded as PR artifacts and linked in PR comments
- Video filenames include the test name for easy cross-platform comparison

## Design Language

The shared design language is defined in `specs/design/design-language.md`.
This is the single source of truth for visual styling across both platforms.

### Mandatory Rules
- **Always read `specs/design/design-language.md` before implementing any UI**
- Use the defined color tokens — never hardcode hex values in views
- Use the icon mapping table to pick the correct platform-specific icon
- Use the spacing tokens for all padding, margins, and gaps
- Use the component style definitions for cards, badges, chips, banners, etc.
- When adding a new color, icon, or style: update the design language doc FIRST,
  then implement on both platforms

### Platform Theme Files
- iOS: `ios/TandemEMT/Core/Theme/AppColors.swift` — color token extensions
- Android: `android/.../ui/theme/Color.kt` — color token definitions
- Both files must contain the exact same hex values from the design language

## Code Generation
- Data models are generated from `specs/api/` definitions
- Run `tools/codegen/generate.sh` after modifying any spec in `specs/api/`
- Never hand-edit generated model files — modify the spec and regenerate

## PR Requirements
- Every feature PR must include changes to BOTH `ios/` and `android/`
- PR description must include links to video recordings from both platforms
- If a PR only touches one platform, it must be labeled `platform-specific` with justification
- CI will fail if a feature spec has test contracts that aren't covered on both platforms
