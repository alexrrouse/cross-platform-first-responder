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
