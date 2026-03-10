# Tandem EMT — Design Language

This is the single source of truth for colors, icons, typography, spacing, and
component styling across both iOS and Android. Both platforms must implement
these values identically to ensure visual parity.

---

## Color Palette

### Brand Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `brand.primary` | `#1A56DB` | Primary actions, active tab, selected chips, links |
| `brand.primaryDark` | `#1242B0` | Pressed state for primary actions |
| `brand.secondary` | `#374151` | Secondary text, icons, supporting UI |
| `brand.accent` | `#F59E0B` | Highlights, badges, warnings |

### Semantic Colors — Status
| Token | Hex | Usage |
|-------|-----|-------|
| `status.dispatched` | `#F59E0B` | Dispatched status badge (amber) |
| `status.enRoute` | `#3B82F6` | En Route status badge (blue) |
| `status.onScene` | `#10B981` | On Scene status badge (green) |
| `status.cleared` | `#6B7280` | Cleared status badge (gray) |

### Semantic Colors — Priority
| Token | Hex | Usage |
|-------|-----|-------|
| `priority.high` | `#DC2626` | High priority border, icon tint, text |
| `priority.medium` | `#F59E0B` | Medium priority accent |
| `priority.low` | `#6B7280` | Low priority (no special accent) |

### Semantic Colors — Incident Type
| Token | Hex | Usage |
|-------|-----|-------|
| `type.fire` | `#DC2626` | Fire incident icon tint |
| `type.ems` | `#2563EB` | EMS incident icon tint |
| `type.hazmat` | `#D97706` | Hazmat incident icon tint |
| `type.rescue` | `#7C3AED` | Rescue incident icon tint |
| `type.other` | `#6B7280` | Other incident icon tint |

### Surface Colors
| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `surface.background` | `#F9FAFB` | `#111827` | Screen background |
| `surface.card` | `#FFFFFF` | `#1F2937` | Card background |
| `surface.cardElevated` | `#FFFFFF` | `#374151` | Elevated card background |
| `surface.banner` | `#FEF3C7` | `#78350F` | Warning/offline banners |

### Text Colors
| Token | Light Mode | Dark Mode | Usage |
|-------|-----------|-----------|-------|
| `text.primary` | `#111827` | `#F9FAFB` | Headings, case numbers |
| `text.secondary` | `#6B7280` | `#9CA3AF` | Timestamps, unit counts |
| `text.onStatus` | `#FFFFFF` | `#FFFFFF` | Text on status badges |
| `text.error` | `#DC2626` | `#F87171` | Error messages |

---

## Icons

### Icon Source
- **iOS**: SF Symbols (Apple's native icon system)
- **Android**: Material Icons (Extended set)

### Icon Mapping
Both platforms must use visually equivalent icons for the same concept:

| Concept | iOS (SF Symbol) | Android (Material Icon) |
|---------|----------------|------------------------|
| **Incident Types** | | |
| Fire | `flame.fill` | `LocalFireDepartment` |
| EMS | `cross.case.fill` | `LocalHospital` |
| Hazmat | `exclamationmark.triangle.fill` | `Warning` |
| Rescue | `figure.wave` | `DirectionsCar` |
| Other | `questionmark.circle.fill` | `ReportProblem` |
| **Tab Bar** | | |
| Incidents | `exclamationmark.triangle` | `Notifications` |
| Map | `map` | `Map` |
| Chat | `message` | `ChatBubble` |
| Settings | `gear` | `Settings` |
| **Actions** | | |
| Refresh | `arrow.clockwise` | `Refresh` |
| Filter | `line.3.horizontal.decrease` | `FilterList` |
| Navigate | `location.fill` | `Navigation` |
| Back | `chevron.left` | `ArrowBack` |
| **States** | | |
| Empty list | `tray` | `Inbox` |
| Error | `exclamationmark.circle` | `ErrorOutline` |
| Offline | `wifi.slash` | `WifiOff` |

### Icon Sizing
| Context | Size |
|---------|------|
| Tab bar | 24pt / 24dp |
| Card type icon | 24pt / 24dp |
| Status icon (inline) | 16pt / 16dp |
| Empty state illustration | 48pt / 48dp |
| Navigation bar icon | 20pt / 20dp |

---

## Typography

Both platforms use their native system fonts (SF Pro on iOS, Roboto on Android)
but must match these semantic styles:

| Token | iOS | Android | Usage |
|-------|-----|---------|-------|
| `heading.screen` | `.title` (28pt bold) | `headlineMedium` | Screen titles |
| `heading.section` | `.title3` (20pt semibold) | `titleMedium` | Section headers |
| `card.title` | `.headline` (17pt semibold) | `titleMedium` (bold) | Case numbers |
| `card.body` | `.body` (17pt regular) | `bodyMedium` | Addresses, descriptions |
| `card.caption` | `.caption` (12pt regular) | `bodySmall` | Timestamps, unit counts |
| `badge.label` | `.caption2` (11pt medium) | `labelSmall` | Status badge text |
| `chip.label` | `.subheadline` (15pt regular) | `labelLarge` | Filter chip text |
| `banner.text` | `.footnote` (13pt regular) | `bodySmall` | Offline/warning banners |

---

## Spacing

Consistent spacing across both platforms using a 4pt/4dp base grid:

| Token | Value | Usage |
|-------|-------|-------|
| `space.xs` | 4 | Tight gaps (between icon and text inline) |
| `space.sm` | 8 | Small gaps (between lines in a card) |
| `space.md` | 12 | Medium gaps (between card sections) |
| `space.lg` | 16 | Standard padding (card internal, screen edges) |
| `space.xl` | 24 | Large gaps (between card and next card) |
| `space.2xl` | 32 | Extra large (section separators) |

---

## Component Styles

### Cards
| Property | Value |
|----------|-------|
| Corner radius | 12pt / 12dp |
| Padding (internal) | 16pt / 16dp |
| Elevation/Shadow | 2pt / 2dp |
| Border (high priority) | 2pt solid `priority.high` |
| Gap between cards | 8pt / 8dp |

### Status Badges
| Property | Value |
|----------|-------|
| Corner radius | 12pt / 12dp (capsule) |
| Padding (horizontal) | 8pt / 8dp |
| Padding (vertical) | 4pt / 4dp |
| Background | Corresponding `status.*` color |
| Text color | `text.onStatus` (#FFFFFF) |
| Font | `badge.label` |

### Filter Chips
| Property | Selected | Unselected |
|----------|----------|------------|
| Background | `brand.primary` | transparent |
| Border | none | 1pt `text.secondary` |
| Text color | `#FFFFFF` | `text.secondary` |
| Corner radius | 16pt / 16dp |
| Padding (horizontal) | 12pt / 12dp |
| Padding (vertical) | 6pt / 6dp |

### Offline Banner
| Property | Value |
|----------|-------|
| Background | `surface.banner` |
| Text color | `text.primary` |
| Icon | Offline icon (see icon mapping) |
| Padding | 12pt / 12dp |
| Position | Top of content, below nav bar |

### Empty State
| Property | Value |
|----------|-------|
| Icon size | 48pt / 48dp |
| Icon color | `text.secondary` |
| Title font | `heading.section` |
| Subtitle font | `card.body` |
| Subtitle color | `text.secondary` |
| Alignment | Center, vertically centered |

### Error State
| Property | Value |
|----------|-------|
| Icon | Error icon (see mapping) |
| Icon color | `text.error` |
| Message font | `card.body` |
| Message color | `text.error` |
| Retry button | Filled, `brand.primary` background |
| Alignment | Center, vertically centered |

---

## Platform Implementation Reference

### iOS — Color Extension
Define in `ios/TandemEMT/Core/Theme/AppColors.swift`:
```swift
extension Color {
    static let brandPrimary = Color(hex: "#1A56DB")
    static let statusDispatched = Color(hex: "#F59E0B")
    // ... etc
}
```

### Android — Color Definitions
Define in `android/.../ui/theme/Color.kt`:
```kotlin
val BrandPrimary = Color(0xFF1A56DB)
val StatusDispatched = Color(0xFFF59E0B)
// ... etc
```

### Updating This Document
When updating the design language:
1. Update this file first
2. Update iOS color/theme extensions
3. Update Android color/theme definitions
4. Verify visual parity with side-by-side screenshots or videos
