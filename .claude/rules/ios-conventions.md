---
paths:
  - "ios/**"
---

# iOS Conventions (Swift / SwiftUI)

## File Organization
```
ios/Features/{FeatureName}/
├── Models/           # Data models (generated from specs/api where possible)
├── ViewModels/       # Business logic, state management (ObservableObject)
├── Views/            # SwiftUI views
└── Tests/            # Unit + UI tests matching specs/test-contracts
```

## Shared Infrastructure
- `ios/TandemEMT/Core/Theme/AppColors.swift` — Color token extensions (must match design language hex values)
- `ios/TandemEMT/Core/Networking/APIClient.swift` — API client
- `ios/TandemEMT/Core/Navigation/AppRouter.swift` — Navigation router

## Naming
- Views: `{Feature}View` (e.g., `IncidentListView`)
- ViewModels: `{Feature}ViewModel` as `ObservableObject`
- State: `struct State` inside ViewModel
- Events: `enum Event` inside ViewModel
- Effects: `enum Effect` inside ViewModel

## Testing
- Unit test files: `{Feature}ViewModelTests.swift` (plural "Tests")
- UI test files: `{Feature}UITests.swift` (plural "Tests")
- Test tags: use `.accessibilityIdentifier("tag_name")`
- UI test video: Xcode test recordings via `xcodebuild test` with `-resultBundlePath`

## Design Tokens
- Never hardcode colors — use `AppColors` extensions
- Never hardcode icons — check the icon mapping table in `specs/design/design-language.md`
- iOS icons use SF Symbols (the `systemName` column in the mapping table)
