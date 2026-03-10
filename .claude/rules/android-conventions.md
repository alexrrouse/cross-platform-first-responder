---
paths:
  - "android/**"
---

# Android Conventions (Kotlin / Jetpack Compose)

## File Organization
```
android/features/{featureName}/
├── models/           # Data models (generated from specs/api where possible)
├── viewmodels/       # Business logic, state management (AndroidX ViewModel)
├── ui/               # Compose screens/components
└── tests/            # Unit + UI tests matching specs/test-contracts
```

## Shared Infrastructure
- `android/.../ui/theme/Color.kt` — Color token definitions (must match design language hex values)
- Android networking, DI (Hilt), and navigation components in `android/app/src/main/`

## Naming
- Screens: `{Feature}Screen` (e.g., `IncidentListScreen`)
- ViewModels: `{Feature}ViewModel` with `@HiltViewModel` / `@Inject`
- State: `data class State` inside ViewModel
- Events: `sealed class Event` inside ViewModel
- Effects: `sealed class Effect` inside ViewModel

## Testing
- Unit test files: `{Feature}ViewModelTest.kt` (singular "Test")
- UI test files: `{Feature}UITest.kt` (singular "Test")
- Test tags: use `Modifier.testTag("tag_name")`
- UI test video: Gradle managed device recordings or `adb screenrecord`

## Design Tokens
- Never hardcode colors — use tokens from `Color.kt`
- Never hardcode icons — check the icon mapping table in `specs/design/design-language.md`
- Android icons use Material Icons (the `materialIcon` column in the mapping table)
