import XCTest
@testable import TandemEMT

@MainActor
final class IncidentListViewModelTests: XCTestCase {

    // MARK: - Helpers

    private func makeIncident(
        id: String = UUID().uuidString,
        caseNumber: String = "INC-001",
        type: IncidentType = .fire,
        status: IncidentStatus = .dispatched,
        priority: Priority = .medium,
        address: String = "123 Main St",
        dispatchTime: Date = Date(),
        assignedUnits: [UnitSummary] = []
    ) -> IncidentSummary {
        IncidentSummary(
            id: id,
            caseNumber: caseNumber,
            type: type,
            priority: priority,
            address: address,
            dispatchTime: dispatchTime,
            status: status,
            assignedUnits: assignedUnits,
            coordinates: Coordinates(latitude: 40.0, longitude: -74.0)
        )
    }

    private func makeSUT(
        result: Result<[IncidentSummary], Error> = .success([]),
        currentUserId: String = "unit-1"
    ) -> (IncidentListViewModel, MockIncidentRepository) {
        let repo = MockIncidentRepository()
        repo.result = result
        let vm = IncidentListViewModel(repository: repo, currentUserId: currentUserId)
        return (vm, repo)
    }

    // MARK: - IL001: Initial load fetches and populates state

    func test_IL001_initialLoadFetchesAndPopulatesState() async {
        let incidents = [
            makeIncident(id: "1", caseNumber: "INC-001"),
            makeIncident(id: "2", caseNumber: "INC-002")
        ]
        let (sut, repo) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()

        XCTAssertFalse(sut.isLoading, "isLoading should be false after load completes")
        XCTAssertEqual(sut.incidents.count, 2, "Should have 2 incidents")
        XCTAssertNil(sut.error, "Should have no error")
        XCTAssertNotNil(sut.lastUpdated, "lastUpdated should be set")
        XCTAssertTrue(repo.fetchIncidentsCalled, "fetchIncidents should have been called")
    }

    // MARK: - IL002: Load failure sets error state

    func test_IL002_loadFailureSetsErrorState() async {
        let (sut, _) = makeSUT(result: .failure(NSError(domain: "test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])))

        await sut.loadIncidents()

        XCTAssertFalse(sut.isLoading, "isLoading should be false after failure")
        XCTAssertNotNil(sut.error, "error should be set")
        XCTAssertTrue(sut.incidents.isEmpty, "incidents should be empty on error")
    }

    // MARK: - IL003: Pull-to-refresh reloads data

    func test_IL003_pullToRefreshReloadsData() async {
        let incidents = [makeIncident(id: "1")]
        let (sut, repo) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()
        let firstUpdate = sut.lastUpdated

        // Small delay so lastUpdated differs
        try? await Task.sleep(nanoseconds: 10_000_000)

        let newIncidents = [makeIncident(id: "1"), makeIncident(id: "2")]
        repo.result = .success(newIncidents)

        await sut.refresh()

        XCTAssertEqual(sut.incidents.count, 2, "Should have refreshed incidents")
        XCTAssertEqual(repo.fetchIncidentsCallCount, 2, "Should have called fetch twice")
        XCTAssertNotEqual(sut.lastUpdated, firstUpdate, "lastUpdated should have changed")
    }

    // MARK: - IL004: Empty incident list from API

    func test_IL004_emptyIncidentListFromAPI() async {
        let (sut, _) = makeSUT(result: .success([]))

        await sut.loadIncidents()

        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.incidents.isEmpty, "incidents should be empty")
        XCTAssertNil(sut.error, "Should have no error for empty list")
    }

    // MARK: - IL010: Filter by active incidents

    func test_IL010_filterByActiveIncidents() async {
        let incidents = [
            makeIncident(id: "1", status: .dispatched),
            makeIncident(id: "2", status: .enRoute),
            makeIncident(id: "3", status: .cleared)
        ]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()
        sut.onFilterChanged(.active)

        XCTAssertEqual(sut.filteredIncidents.count, 2, "Only active incidents should be shown")
        XCTAssertTrue(sut.filteredIncidents.allSatisfy { $0.status.isActive }, "All should be active")
    }

    // MARK: - IL011: Filter by my assigned incidents

    func test_IL011_filterByMyAssignedIncidents() async {
        let incidents = [
            makeIncident(id: "1", assignedUnits: [UnitSummary(id: "unit-1", name: "Engine 1")]),
            makeIncident(id: "2", assignedUnits: [UnitSummary(id: "unit-2", name: "Engine 2")]),
            makeIncident(id: "3", assignedUnits: [UnitSummary(id: "unit-1", name: "Engine 1"), UnitSummary(id: "unit-3", name: "Ladder 1")])
        ]
        let (sut, _) = makeSUT(result: .success(incidents), currentUserId: "unit-1")

        await sut.loadIncidents()
        sut.onFilterChanged(.myAssigned)

        XCTAssertEqual(sut.filteredIncidents.count, 2, "Only my assigned incidents should be shown")
        XCTAssertTrue(sut.filteredIncidents.allSatisfy { incident in
            incident.assignedUnits.contains { $0.id == "unit-1" }
        })
    }

    // MARK: - IL012: Filter resets to all

    func test_IL012_filterResetsToAll() async {
        let incidents = [
            makeIncident(id: "1", status: .dispatched),
            makeIncident(id: "2", status: .cleared)
        ]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()
        sut.onFilterChanged(.active)
        XCTAssertEqual(sut.filteredIncidents.count, 1)

        sut.onFilterChanged(.all)
        XCTAssertEqual(sut.filteredIncidents.count, 2, "All incidents should be shown when filter is all")
    }

    // MARK: - IL020: WebSocket update adds new incident

    func test_IL020_webSocketUpdateAddsNewIncident() async {
        let incidents = [
            makeIncident(id: "1"),
            makeIncident(id: "2"),
            makeIncident(id: "3")
        ]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()
        XCTAssertEqual(sut.incidents.count, 3)

        let newIncident = makeIncident(id: "4", dispatchTime: Date().addingTimeInterval(100))
        sut.onIncidentUpdated(newIncident)

        XCTAssertEqual(sut.incidents.count, 4, "Should now have 4 incidents")
        XCTAssertEqual(sut.filteredIncidents.first?.id, "4", "New incident should be at top (newest first)")
    }

    // MARK: - IL021: WebSocket update modifies existing incident

    func test_IL021_webSocketUpdateModifiesExistingIncident() async {
        let incidents = [
            makeIncident(id: "123", status: .dispatched)
        ]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()

        let updated = makeIncident(id: "123", status: .enRoute)
        sut.onIncidentUpdated(updated)

        XCTAssertEqual(sut.incidents.count, 1, "Count should remain 1")
        XCTAssertEqual(sut.incidents.first?.status, .enRoute, "Status should be updated to enRoute")
    }

    // MARK: - IL022: WebSocket update removes cleared incident

    func test_IL022_webSocketUpdateRemovesClearedIncident() async {
        let incidents = [
            makeIncident(id: "123", status: .dispatched),
            makeIncident(id: "456", status: .onScene)
        ]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()

        let cleared = makeIncident(id: "123", status: .cleared)
        sut.onIncidentUpdated(cleared)

        XCTAssertEqual(sut.incidents.count, 1, "Cleared incident should be removed")
        XCTAssertNil(sut.incidents.first(where: { $0.id == "123" }), "Incident 123 should not exist")
    }

    // MARK: - IL030: Tapping incident triggers navigation

    func test_IL030_tappingIncidentTriggersNavigation() async {
        let (sut, _) = makeSUT()

        XCTAssertNil(sut.navigationTarget, "No navigation target initially")

        sut.onIncidentTapped("123")

        XCTAssertEqual(sut.navigationTarget, "123", "Navigation target should be set to incident id")
    }

    // MARK: - IL040: Incidents sorted by dispatch time descending

    func test_IL040_incidentsSortedByDispatchTimeDescending() async {
        let now = Date()
        let incidents = [
            makeIncident(id: "old", dispatchTime: now.addingTimeInterval(-3600)),
            makeIncident(id: "newest", dispatchTime: now.addingTimeInterval(100)),
            makeIncident(id: "middle", dispatchTime: now)
        ]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()

        let ids = sut.filteredIncidents.map { $0.id }
        XCTAssertEqual(ids, ["newest", "middle", "old"], "Incidents should be sorted newest first")
    }

    // MARK: - IL041: High priority incidents distinguished

    func test_IL041_highPriorityIncidentsDistinguished() async {
        let incidents = [
            makeIncident(id: "1", priority: .high),
            makeIncident(id: "2", priority: .medium),
            makeIncident(id: "3", priority: .low)
        ]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()

        let highPriority = sut.filteredIncidents.filter { $0.priority == .high }
        XCTAssertEqual(highPriority.count, 1, "Should have 1 high priority incident")
        XCTAssertEqual(highPriority.first?.id, "1")
    }

    // MARK: - IL060: Offline mode shows cached data with banner

    func test_IL060_offlineModeShowsCachedDataWithBanner() async {
        let incidents = [makeIncident(id: "1")]
        let (sut, _) = makeSUT(result: .success(incidents))

        await sut.loadIncidents()
        sut.setOffline(true)

        XCTAssertTrue(sut.isOffline, "Should be offline")
        XCTAssertEqual(sut.incidents.count, 1, "Cached incidents should still be available")
    }

    // MARK: - IL061: Offline mode with no cache shows empty state

    func test_IL061_offlineModeNoCacheShowsEmptyState() async {
        let (sut, _) = makeSUT(result: .success([]))

        await sut.loadIncidents()
        sut.setOffline(true)

        XCTAssertTrue(sut.isOffline, "Should be offline")
        XCTAssertTrue(sut.incidents.isEmpty, "Should have no incidents")
    }
}
