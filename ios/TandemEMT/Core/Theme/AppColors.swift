import SwiftUI

// MARK: - Color Hex Initializer

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Brand Colors

extension Color {
    static let brandPrimary = Color(hex: "1A56DB")
    static let brandPrimaryDark = Color(hex: "1242B0")
    static let brandSecondary = Color(hex: "374151")
    static let brandAccent = Color(hex: "F59E0B")
}

// MARK: - Status Colors

extension Color {
    static let statusDispatched = Color(hex: "F59E0B")
    static let statusEnRoute = Color(hex: "3B82F6")
    static let statusOnScene = Color(hex: "10B981")
    static let statusCleared = Color(hex: "6B7280")

    static func statusColor(_ status: IncidentStatus) -> Color {
        switch status {
        case .dispatched: return .statusDispatched
        case .enRoute: return .statusEnRoute
        case .onScene: return .statusOnScene
        case .cleared: return .statusCleared
        }
    }
}

// MARK: - Priority Colors

extension Color {
    static let priorityHigh = Color(hex: "DC2626")
    static let priorityMedium = Color(hex: "F59E0B")
    static let priorityLow = Color(hex: "6B7280")

    static func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high: return .priorityHigh
        case .medium: return .priorityMedium
        case .low: return .priorityLow
        }
    }
}

// MARK: - Incident Type Tint Colors

extension Color {
    static let typeFire = Color(hex: "DC2626")
    static let typeEMS = Color(hex: "2563EB")
    static let typeHazmat = Color(hex: "D97706")
    static let typeRescue = Color(hex: "7C3AED")
    static let typeOther = Color(hex: "6B7280")

    static func incidentTypeTint(_ type: IncidentType) -> Color {
        switch type {
        case .fire: return .typeFire
        case .ems: return .typeEMS
        case .hazmat: return .typeHazmat
        case .rescue: return .typeRescue
        case .other: return .typeOther
        }
    }
}

// MARK: - Surface Colors

extension Color {
    static let surfaceBackground = Color("surfaceBackground", bundle: nil)
    static let surfaceCard = Color("surfaceCard", bundle: nil)
    static let surfaceBanner = Color("surfaceBanner", bundle: nil)

    // Programmatic fallbacks for light/dark mode
    static func surfaceBackgroundAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "111827") : Color(hex: "F9FAFB")
    }

    static func surfaceCardAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "1F2937") : Color(hex: "FFFFFF")
    }

    static func surfaceBannerAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "78350F") : Color(hex: "FEF3C7")
    }
}

// MARK: - Text Colors

extension Color {
    static func textPrimaryAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "F9FAFB") : Color(hex: "111827")
    }

    static func textSecondaryAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "9CA3AF") : Color(hex: "6B7280")
    }

    static let textOnStatus = Color(hex: "FFFFFF")

    static func textErrorAdaptive(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(hex: "F87171") : Color(hex: "DC2626")
    }
}

// MARK: - Component Constants

enum AppTheme {
    static let cardCornerRadius: CGFloat = 12
    static let cardPadding: CGFloat = 16
    static let cardShadowRadius: CGFloat = 2
    static let cardHighPriorityBorderWidth: CGFloat = 2
    static let statusBadgeCornerRadius: CGFloat = 12
    static let statusBadgeHPadding: CGFloat = 8
    static let statusBadgeVPadding: CGFloat = 4
    static let filterChipCornerRadius: CGFloat = 16
    static let filterChipHPadding: CGFloat = 12
    static let filterChipVPadding: CGFloat = 6
}
