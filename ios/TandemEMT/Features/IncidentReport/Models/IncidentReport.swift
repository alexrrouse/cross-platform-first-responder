import Foundation

struct IncidentReport: Identifiable, Codable {
    let id: String
    var patientName: String
    var patientAge: Int?
    var chiefComplaint: String
    var vitalSigns: VitalSigns
    var treatments: [String]
    var procedures: [String]
    var disposition: Disposition?
    var transportDestination: String?
    var narrative: String
    var timestamps: ReportTimestamps
    var status: ReportStatus
    let createdAt: Date
    var updatedAt: Date
}

struct VitalSigns: Codable, Equatable {
    var pulseRate: Int?
    var bloodPressureSystolic: Int?
    var bloodPressureDiastolic: Int?
    var respirationRate: Int?
    var spO2: Int?
}

struct ReportTimestamps: Codable, Equatable {
    var arrivalTime: Date?
    var patientContactTime: Date?
    var transportTime: Date?
}

enum Disposition: String, Codable, CaseIterable {
    case transported
    case refusal
    case noPatient
    case deadOnArrival
    case other

    var displayName: String {
        switch self {
        case .transported: return "Transported"
        case .refusal: return "Refusal"
        case .noPatient: return "No Patient"
        case .deadOnArrival: return "Dead on Arrival"
        case .other: return "Other"
        }
    }
}

enum ReportStatus: String, Codable {
    case draft
    case submitted
}
