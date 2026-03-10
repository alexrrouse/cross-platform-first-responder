import Foundation

protocol APIClientProtocol: Sendable {
    // Methods will be added as features are implemented
}

final class APIClient: APIClientProtocol {
    static let shared = APIClient()

    private init() {}
}

final class MockAPIClient: APIClientProtocol {
    init() {}
}
