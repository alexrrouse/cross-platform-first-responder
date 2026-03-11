---
paths:
  - "android/**"
---

# Android Conventions (Kotlin / Jetpack Compose)

## File Organization
```
android/app/src/main/java/com/tandem/emt/features/{featureName}/
├── models/                        # Data models
├── ui/                            # Compose screens/components
├── {Feature}ViewModel.kt          # ViewModel (feature root)
└── {Feature}Repository.kt         # Repository interface + impl (feature root)
```

## Shared Infrastructure
- `android/app/src/main/java/com/tandem/emt/ui/theme/Color.kt` — Color token definitions
- `android/app/src/main/java/com/tandem/emt/ui/theme/DesignTokens.kt` — Spacing/typography tokens
- `android/app/src/main/java/com/tandem/emt/navigation/AppNavigation.kt` — Navigation graph

## Naming
- Screens: `{Feature}Screen` (e.g., `IncidentListScreen`)
- ViewModels: `{Feature}ViewModel` extending `ViewModel()`
- State: Top-level `data class {Feature}UiState` (outside ViewModel class)
- Events: Public `fun` methods on ViewModel (e.g., `fun onRefresh()`)
- Effects: Top-level `sealed class {Feature}Effect` emitted via `Channel`

## Testing
- Unit test dir: `android/app/src/test/java/com/tandem/emt/features/{featureName}/`
- Unit test file: `{Feature}ViewModelTest.kt` (singular "Test")
- UI test dir: `android/app/src/androidTest/java/com/tandem/emt/features/{featureName}/`
- UI test file: `{Feature}UITest.kt` (singular "Test")
- **Test tags: MUST use `Modifier.testTag("tag_name")` on every testable element** — required for UI test parity with iOS `.accessibilityIdentifier()`
- UI test video: Run `./tools/ci/record-ui-tests.sh android` — records emulator via `adb screenrecord`, saves mp4 to `artifacts/videos/android/`
- **LazyColumn testing:** Use `onNodeWithTag("list_tag").performScrollToNode(hasTestTag("item_tag"))` — `performScrollTo()` doesn't work for items not yet composed in lazy lists

## Design Tokens
- Never hardcode colors — use tokens from `Color.kt`
- Never hardcode icons — check the icon mapping table in `specs/design/design-language.md`
- Android icons use Material Icons (the `materialIcon` column in the mapping table)
