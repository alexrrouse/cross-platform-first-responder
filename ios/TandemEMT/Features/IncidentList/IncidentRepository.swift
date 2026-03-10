import Foundation

protocol IncidentRepositoryProtocol {
    func fetchIncidents() async throws -> [IncidentSummary]
}

final class IncidentRepository: IncidentRepositoryProtocol {
    func fetchIncidents() async throws -> [IncidentSummary] {
        // Simulate network delay — real API isn't built yet
        try await Task.sleep(nanoseconds: 500_000_000)
        return []
    }
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
