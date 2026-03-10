---
paths:
  - "ios/**/Views/**"
  - "ios/**/Theme/**"
  - "android/**/ui/**"
  - "android/**/theme/**"
  - "specs/design/**"
---

# Design Language Rules

The shared design language is defined in `specs/design/design-language.md`.
This is the single source of truth for visual styling across both platforms.

## Mandatory
- **Always read `specs/design/design-language.md` before implementing any UI**
- Use the defined color tokens — never hardcode hex values in views
- Use the icon mapping table to pick the correct platform-specific icon
- Use the spacing tokens for all padding, margins, and gaps
- Use the component style definitions for cards, badges, chips, banners, etc.

## Adding New Tokens
When adding a new color, icon, or style:
1. Update `specs/design/design-language.md` FIRST
2. Then implement on both platforms:
   - iOS: `ios/TandemEMT/Core/Theme/AppColors.swift`
   - Android: `android/.../ui/theme/Color.kt`
3. Both platform files must contain the exact same hex values from the design language
