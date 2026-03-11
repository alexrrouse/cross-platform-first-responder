import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }

    // MARK: - Brand
    static let brandPrimary = Color(hex: "#1A56DB")
    static let brandPrimaryDark = Color(hex: "#1242B0")
    static let brandSecondary = Color(hex: "#374151")
    static let brandAccent = Color(hex: "#F59E0B")

    // MARK: - Status
    static let statusDispatched = Color(hex: "#F59E0B")
    static let statusEnRoute = Color(hex: "#3B82F6")
    static let statusOnScene = Color(hex: "#10B981")
    static let statusCleared = Color(hex: "#6B7280")

    // MARK: - Priority
    static let priorityHigh = Color(hex: "#DC2626")
    static let priorityMedium = Color(hex: "#F59E0B")
    static let priorityLow = Color(hex: "#6B7280")

    // MARK: - Incident Type
    static let typeFire = Color(hex: "#DC2626")
    static let typeEms = Color(hex: "#2563EB")
    static let typeHazmat = Color(hex: "#D97706")
    static let typeRescue = Color(hex: "#7C3AED")
    static let typeOther = Color(hex: "#6B7280")

    // MARK: - Surface
    static let surfaceBackground = Color("SurfaceBackground")
    static let surfaceCard = Color("SurfaceCard")
    static let surfaceCardElevated = Color("SurfaceCardElevated")
    static let surfaceBanner = Color("SurfaceBanner")

    // MARK: - Text
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textOnStatus = Color.white
    static let textError = Color("TextError")
}
