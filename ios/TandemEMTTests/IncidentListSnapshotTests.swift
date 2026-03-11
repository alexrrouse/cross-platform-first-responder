import SnapshotTesting
import SwiftUI
import XCTest

@testable import TandemEMT

final class IncidentListSnapshotTests: XCTestCase {

    func test_incidentListSnapshot() {
        let view = ContentView()
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds

        assertSnapshot(of: vc, as: .image(on: .iPhone13))
    }
}
