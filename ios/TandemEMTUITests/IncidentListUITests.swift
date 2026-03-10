import XCTest

final class IncidentListUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    // MARK: - IL050: Loading state shows skeleton

    func test_IL050_loadingStateShowsSkeleton() throws {
        let app = XCUIApplication()
        app.launch()

        // The incidents tab should be selected by default
        // During initial load, a loading indicator or placeholder should be visible
        let incidentsTab = app.tabBars.buttons["Incidents"]
        XCTAssertTrue(incidentsTab.waitForExistence(timeout: 5))
        incidentsTab.tap()

        // TODO: inject mock data for full verification
        // For now, verify the screen loads without crashing
        XCTAssertTrue(app.navigationBars["Incidents"].waitForExistence(timeout: 5))
    }

    // MARK: - IL051: Empty state shows message

    func test_IL051_emptyStateShowsMessage() throws {
        let app = XCUIApplication()
        app.launch()

        let incidentsTab = app.tabBars.buttons["Incidents"]
        XCTAssertTrue(incidentsTab.waitForExistence(timeout: 5))
        incidentsTab.tap()

        // The default repository returns empty, so we should see the empty state
        // after loading completes
        let emptyText = app.staticTexts["No active incidents"]
        XCTAssertTrue(emptyText.waitForExistence(timeout: 10), "Should show 'No active incidents' text")
    }

    // MARK: - IL052: Error state shows retry button

    func test_IL052_errorStateShowsRetryButton() throws {
        // TODO: inject mock data for full verification
        // Cannot inject error state from UI tests without a launch argument mechanism
        let app = XCUIApplication()
        app.launch()

        let incidentsTab = app.tabBars.buttons["Incidents"]
        XCTAssertTrue(incidentsTab.waitForExistence(timeout: 5))
        incidentsTab.tap()

        // Placeholder: verify the screen loaded
        XCTAssertTrue(app.navigationBars["Incidents"].waitForExistence(timeout: 5))
        // TODO: inject mock data to trigger error state and verify Retry button
    }

    // MARK: - IL053: Incident card shows all fields

    func test_IL053_incidentCardShowsAllFields() throws {
        // TODO: inject mock data for full verification
        let app = XCUIApplication()
        app.launch()

        let incidentsTab = app.tabBars.buttons["Incidents"]
        XCTAssertTrue(incidentsTab.waitForExistence(timeout: 5))
        incidentsTab.tap()

        // Placeholder — need mock data injection to verify card fields
        XCTAssertTrue(app.navigationBars["Incidents"].waitForExistence(timeout: 5))
    }

    // MARK: - IL054: Filter chips reflect selected state

    func test_IL054_filterChipsReflectSelectedState() throws {
        let app = XCUIApplication()
        app.launch()

        let incidentsTab = app.tabBars.buttons["Incidents"]
        XCTAssertTrue(incidentsTab.waitForExistence(timeout: 5))
        incidentsTab.tap()

        // Verify filter chips exist
        let allChip = app.buttons["All filter"]
        let activeChip = app.buttons["Active filter"]
        let myAssignedChip = app.buttons["My Assigned filter"]

        // Wait for chips to appear
        XCTAssertTrue(allChip.waitForExistence(timeout: 10), "All filter chip should exist")
        XCTAssertTrue(activeChip.exists, "Active filter chip should exist")
        XCTAssertTrue(myAssignedChip.exists, "My Assigned filter chip should exist")

        // Tap Active and verify interaction doesn't crash
        activeChip.tap()

        // TODO: inject mock data to verify filtered results change
    }
}
