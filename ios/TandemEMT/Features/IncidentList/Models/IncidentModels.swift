import Foundation

enum IncidentType: String, Codable, CaseIterable {
    case fire, ems, hazmat, rescue, other
}

enum Priority: String, Codable {
    case high, medium, low
}

enum IncidentStatus: String, Codable {
    case dispatched, enRoute, onScene, cleared

    var isActive: Bool {
        self != .cleared
    }
}

struct UnitSummary: Codable, Identifiable, Equatable {
    let id: String
    let name: String
}

struct Coordinates: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}

struct IncidentSummary: Codable, Identifiable, Equatable {
    let id: String
    let caseNumber: String
    let type: IncidentType
    let priority: Priority
    let address: String
    let dispatchTime: Date
    let status: IncidentStatus
    let assignedUnits: [UnitSummary]
    let coordinates: Coordinates
}

enum FilterStatus: String, CaseIterable {
    case all, active, myAssigned

    var displayName: String {
        switch self {
        case .all: return "All"
        case .active: return "Active"
        case .myAssigned: return "My Assigned"
        }
    }
}
