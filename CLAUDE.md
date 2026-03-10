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

## Architecture

### Shared Specs (Single Source of Truth)
```
specs/
├── api/              # OpenAPI/protobuf — generates models for both platforms
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

### Test Naming
Tests must reference the contract case ID so we can trace parity:
- iOS: `func test_{caseId}_{description}()`
- Android: `fun test_{caseId}_{description}()`

### What to Test
- **Unit tests**: ViewModel logic, state transitions, data transformations
- **UI tests**: Critical user flows, accessibility, screen state rendering
- **Both platforms must have the same test coverage** for contract cases

### UI Test Video Recording
- UI tests record screen videos during CI runs
- iOS: Xcode test recordings via `xcodebuild test` with `-resultBundlePath`
- Android: Gradle managed device recordings or `adb screenrecord`
- Videos are uploaded as PR artifacts and linked in PR comments

## Code Generation
- Data models are generated from `specs/api/` definitions
- Run `tools/codegen/generate.sh` after modifying any spec in `specs/api/`
- Never hand-edit generated model files — modify the spec and regenerate

## PR Requirements
- Every feature PR must include changes to BOTH `ios/` and `android/`
- PR description must include links to video recordings from both platforms
- If a PR only touches one platform, it must be labeled `platform-specific` with justification
- CI will fail if a feature spec has test contracts that aren't covered on both platforms
