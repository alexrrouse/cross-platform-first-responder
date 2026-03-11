import Foundation

protocol IncidentReportRepositoryProtocol: Sendable {
    func submitReport(_ report: IncidentReport) async throws -> IncidentReport
}

final class IncidentReportRepository: IncidentReportRepositoryProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }

    func submitReport(_ report: IncidentReport) async throws -> IncidentReport {
        // Stub: simulate network delay and return the report as submitted
        try await Task.sleep(nanoseconds: 1_000_000_000)
        var submitted = report
        submitted.status = .submitted
        submitted.updatedAt = Date()
        return submitted
    }
}

final class MockIncidentReportRepository: IncidentReportRepositoryProtocol, @unchecked Sendable {
    var submitResult: Result<IncidentReport, Error> = .success(
        IncidentReport(
            id: "mock-id",
            patientName: "",
            patientAge: nil,
            chiefComplaint: "",
            vitalSigns: VitalSigns(),
            treatments: [],
            procedures: [],
            disposition: nil,
            transportDestination: nil,
            narrative: "",
            timestamps: ReportTimestamps(),
            status: .submitted,
            createdAt: Date(),
            updatedAt: Date()
        )
    )

    func submitReport(_ report: IncidentReport) async throws -> IncidentReport {
        return try submitResult.get()
    }
}
