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
ios/Features/{FeatureName}/        android/features/{featureName}/
├── Models/                        ├── models/
├── ViewModels/                    ├── viewmodels/
├── Views/                         ├── ui/
└── Tests/                         └── tests/
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
