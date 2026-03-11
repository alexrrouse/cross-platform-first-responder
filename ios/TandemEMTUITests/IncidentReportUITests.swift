import XCTest

final class IncidentReportUITests: XCTestCase {

    /// Demo: shows the incident list with dummy data, pauses for video capture.
    func test_incidentListDemo() {
        let app = XCUIApplication()
        app.launch()

        // Verify the incident list loads with cards
        let firstCard = app.descendants(matching: .any)["incident_card_1"]
        XCTAssertTrue(firstCard.waitForExistence(timeout: 10), "First incident card not found")

        // Pause to let the video capture the full list
        sleep(3)

        // Verify multiple cards are visible
        XCTAssertTrue(app.descendants(matching: .any)["incident_card_2"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["incident_card_3"].exists)

        // Verify the new report FAB is present
        XCTAssertTrue(app.buttons["new_report_button"].exists)

        // Scroll down to show remaining cards
        app.swipeUp()
        sleep(2)
    }
}
