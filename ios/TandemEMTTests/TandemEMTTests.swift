import XCTest
@testable import TandemEMT

final class TandemEMTTests: XCTestCase {

    func testAppLaunches() throws {
        // Basic sanity test — app module is importable and test infrastructure works
        XCTAssertTrue(true)
    }

    @MainActor
    func testAppRouterInitialState() throws {
        let router = AppRouter()
        XCTAssertTrue(router.path.isEmpty)
    }
}
