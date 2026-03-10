# Tandem EMT App

Dual-native mobile app for EMT/Fire response. iOS (Swift/SwiftUI) + Android (Kotlin/Jetpack Compose).

**Every feature must be implemented on BOTH platforms simultaneously.**

## Rules

Detailed rules are in `.claude/rules/`:

| Rule File | Scope | What It Covers |
|-----------|-------|----------------|
| `cross-platform-parity.md` | Always | Mandatory dual-platform workflow, "never do" list |
| `architecture.md` | Always | Shared specs, mirrored structure, MVVM, State/Event/Effect |
| `ios-conventions.md` | `ios/**` | Swift/SwiftUI naming, file org, theme, SF Symbols |
| `android-conventions.md` | `android/**` | Kotlin/Compose naming, file org, theme, Material Icons |
| `testing.md` | Test files, contracts | Test contracts, naming parity, test tags, UI test video |
| `design-language.md` | UI/theme files | Design tokens, color/icon/spacing rules |
| `codegen-and-specs.md` | `specs/**`, `tools/**` | Code generation, spec workflow |
| `pr-requirements.md` | Always | PR checklist, CI expectations |

## Quick Reference

- Feature specs: `specs/features/`
- Test contracts: `specs/test-contracts/`
- Design tokens: `specs/design/design-language.md`
- iOS theme: `ios/TandemEMT/Core/Theme/AppColors.swift`
- Android theme: `android/.../ui/theme/Color.kt`
- Codegen: `tools/codegen/generate.sh`
- CI parity check: `tools/ci/validate-test-parity.sh`
