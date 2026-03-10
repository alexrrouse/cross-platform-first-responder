import Foundation

protocol IncidentRepositoryProtocol {
    func fetchIncidents() async throws -> [IncidentSummary]
}

final class IncidentRepository: IncidentRepositoryProtocol {
    func fetchIncidents() async throws -> [IncidentSummary] {
        // Simulate network delay — real API isn't built yet
        try await Task.sleep(nanoseconds: 500_000_000)
        return IncidentRepository.sampleData
    }

    static let sampleData: [IncidentSummary] = [
        IncidentSummary(
            id: "INC-001",
            caseNumber: "2026-00142",
            type: .fire,
            priority: .high,
            address: "742 Evergreen Terrace",
            dispatchTime: Date().addingTimeInterval(-180),
            status: .dispatched,
            assignedUnits: [
                UnitSummary(id: "E1", name: "Engine 1"),
                UnitSummary(id: "L1", name: "Ladder 1")
            ],
            coordinates: Coordinates(latitude: 40.7128, longitude: -74.0060)
        ),
        IncidentSummary(
            id: "INC-002",
            caseNumber: "2026-00141",
            type: .ems,
            priority: .high,
            address: "315 Oak Avenue, Apt 4B",
            dispatchTime: Date().addingTimeInterval(-720),
            status: .enRoute,
            assignedUnits: [
                UnitSummary(id: "M3", name: "Medic 3")
            ],
            coordinates: Coordinates(latitude: 40.7580, longitude: -73.9855)
        ),
        IncidentSummary(
            id: "INC-003",
            caseNumber: "2026-00139",
            type: .hazmat,
            priority: .medium,
            address: "1200 Industrial Blvd",
            dispatchTime: Date().addingTimeInterval(-2400),
            status: .onScene,
            assignedUnits: [
                UnitSummary(id: "HZ1", name: "Hazmat 1"),
                UnitSummary(id: "E4", name: "Engine 4"),
                UnitSummary(id: "BC2", name: "Battalion 2")
            ],
            coordinates: Coordinates(latitude: 40.7282, longitude: -73.7949)
        ),
        IncidentSummary(
            id: "INC-004",
            caseNumber: "2026-00138",
            type: .rescue,
            priority: .medium,
            address: "Highway 101 & Exit 14",
            dispatchTime: Date().addingTimeInterval(-3600),
            status: .onScene,
            assignedUnits: [
                UnitSummary(id: "R2", name: "Rescue 2"),
                UnitSummary(id: "E7", name: "Engine 7")
            ],
            coordinates: Coordinates(latitude: 40.6892, longitude: -74.0445)
        ),
        IncidentSummary(
            id: "INC-005",
            caseNumber: "2026-00137",
            type: .ems,
            priority: .low,
            address: "55 Maple Street",
            dispatchTime: Date().addingTimeInterval(-5400),
            status: .enRoute,
            assignedUnits: [
                UnitSummary(id: "M1", name: "Medic 1")
            ],
            coordinates: Coordinates(latitude: 40.7484, longitude: -73.9967)
        ),
    ]
}

final class MockIncidentRepository: IncidentRepositoryProtocol {
    var result: Result<[IncidentSummary], Error> = .success([])
    private(set) var fetchIncidentsCalled = false
    private(set) var fetchIncidentsCallCount = 0

    func fetchIncidents() async throws -> [IncidentSummary] {
        fetchIncidentsCalled = true
        fetchIncidentsCallCount += 1
        return try result.get()
    }
}
