---
paths:
  - "ios/**"
---

# iOS Conventions (Swift / SwiftUI)

## File Organization
```
ios/TandemEMT/Features/{FeatureName}/
├── Models/                        # Data models
├── ViewModels/                    # ViewModel (ObservableObject)
├── Views/                         # SwiftUI views
└── {Feature}Repository.swift      # Repository protocol + impl (feature root)
```

## Shared Infrastructure
- `ios/TandemEMT/Core/Theme/AppColors.swift` — Color token extensions (must match design language hex values)
- `ios/TandemEMT/Core/Networking/APIClient.swift` — API client
- `ios/TandemEMT/Core/Navigation/AppRouter.swift` — Navigation router

## Naming
- Views: `{Feature}View` (e.g., `IncidentListView`)
- ViewModels: `{Feature}ViewModel` as `@MainActor ObservableObject`
- State: `@Published` properties directly on ViewModel (not a nested struct)
- Events: Public `func` methods on ViewModel (e.g., `func onRefresh()`)
- Effects: `@Published` properties (e.g., `navigationTarget: String?`)

## Testing
- Unit test dir: `ios/TandemEMTTests/{Feature}Tests/`
- Unit test file: `{Feature}ViewModelTests.swift` (plural "Tests")
- UI test dir: `ios/TandemEMTUITests/`
- UI test file: `{Feature}UITests.swift` (plural "Tests")
- **Test tags: MUST use `.accessibilityIdentifier("tag_name")` on every testable element** — this is required for UI test parity with Android's `Modifier.testTag()`
- UI test video: Xcode test recordings via `xcodebuild test` with `-resultBundlePath`

## Design Tokens
- Never hardcode colors — use `AppColors` extensions
- Never hardcode icons — check the icon mapping table in `specs/design/design-language.md`
- iOS icons use SF Symbols (the `systemName` column in the mapping table)
