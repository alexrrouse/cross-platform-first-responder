import XCTest
@testable import TandemEMT

@MainActor
final class IncidentReportViewModelTests: XCTestCase {

    private func makeViewModel(
        submitResult: Result<IncidentReport, Error> = .success(
            IncidentReport(
                id: "mock", patientName: "", patientAge: nil, chiefComplaint: "",
                vitalSigns: VitalSigns(), treatments: [], procedures: [],
                disposition: nil, transportDestination: nil, narrative: "",
                timestamps: ReportTimestamps(), status: .submitted,
                createdAt: Date(), updatedAt: Date()
            )
        )
    ) -> (IncidentReportViewModel, MockIncidentReportRepository) {
        let repo = MockIncidentReportRepository()
        repo.submitResult = submitResult
        let vm = IncidentReportViewModel(repository: repo, dateProvider: { Date(timeIntervalSince1970: 1000) })
        return (vm, repo)
    }

    private func fillRequiredFields(_ vm: IncidentReportViewModel) {
        vm.onFieldChanged(field: "patientName", value: "John Doe")
        vm.onFieldChanged(field: "chiefComplaint", value: "Chest pain")
        vm.onDispositionSelected(.refusal)
    }

    // MARK: - IR001

    func test_IR001_initialStateHasEmptyFields() {
        let (vm, _) = makeViewModel()
        XCTAssertEqual(vm.patientName, "")
        XCTAssertEqual(vm.patientAge, "")
        XCTAssertEqual(vm.chiefComplaint, "")
        XCTAssertEqual(vm.pulseRate, "")
        XCTAssertEqual(vm.bloodPressureSystolic, "")
        XCTAssertEqual(vm.bloodPressureDiastolic, "")
        XCTAssertEqual(vm.respirationRate, "")
        XCTAssertEqual(vm.spO2, "")
        XCTAssertTrue(vm.treatments.isEmpty)
        XCTAssertTrue(vm.procedures.isEmpty)
        XCTAssertNil(vm.disposition)
        XCTAssertEqual(vm.transportDestination, "")
        XCTAssertEqual(vm.narrative, "")
        XCTAssertNil(vm.arrivalTime)
        XCTAssertNil(vm.patientContactTime)
        XCTAssertNil(vm.transportTime)
        XCTAssertFalse(vm.isSubmitting)
        XCTAssertTrue(vm.validationErrors.isEmpty)
        XCTAssertFalse(vm.isSaved)
    }

    // MARK: - IR002

    func test_IR002_fieldChangeUpdatesState() {
        let (vm, _) = makeViewModel()
        vm.onFieldChanged(field: "patientName", value: "John")
        XCTAssertEqual(vm.patientName, "John")
    }

    // MARK: - IR003

    func test_IR003_submitWithValidDataSetsSubmitting() {
        let (vm, _) = makeViewModel()
        fillRequiredFields(vm)
        vm.onSubmit()
        XCTAssertTrue(vm.isSubmitting)
        XCTAssertTrue(vm.validationErrors.isEmpty)
    }

    // MARK: - IR004

    func test_IR004_submitSuccessEmitsNavigateBack() async throws {
        let (vm, _) = makeViewModel()
        fillRequiredFields(vm)
        vm.onSubmit()

        try await Task.sleep(nanoseconds: 300_000_000)
        XCTAssertFalse(vm.isSubmitting)
        XCTAssertEqual(vm.effect, .navigateBack)
    }

    // MARK: - IR005

    func test_IR005_submitFailureShowsError() async throws {
        let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error"])
        let (vm, _) = makeViewModel(submitResult: .failure(error))
        fillRequiredFields(vm)
        vm.onSubmit()

        try await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertFalse(vm.isSubmitting)
        if case .showSubmitError = vm.effect {
            // pass
        } else {
            XCTFail("Expected showSubmitError effect")
        }
    }

    // MARK: - IR006

    func test_IR006_submitWithMissingRequiredFieldsSetsValidationErrors() {
        let (vm, _) = makeViewModel()
        vm.onSubmit()
        XCTAssertNotNil(vm.validationErrors["patientName"])
        XCTAssertNotNil(vm.validationErrors["chiefComplaint"])
        XCTAssertNotNil(vm.validationErrors["disposition"])
        XCTAssertFalse(vm.isSubmitting)
    }

    // MARK: - IR007

    func test_IR007_validationErrorClearsWhenFieldCorrected() {
        let (vm, _) = makeViewModel()
        vm.onSubmit() // sets validation errors
        XCTAssertNotNil(vm.validationErrors["patientName"])
        vm.onFieldChanged(field: "patientName", value: "Jane")
        XCTAssertNil(vm.validationErrors["patientName"])
    }

    // MARK: - IR008

    func test_IR008_patientAgeValidatesRange() {
        let (vm, _) = makeViewModel()
        fillRequiredFields(vm)
        vm.onFieldChanged(field: "patientAge", value: "200")
        vm.onSubmit()
        XCTAssertNotNil(vm.validationErrors["patientAge"])
    }

    // MARK: - IR009

    func test_IR009_vitalSignsValidateRanges() {
        let (vm, _) = makeViewModel()
        fillRequiredFields(vm)
        vm.onFieldChanged(field: "pulseRate", value: "999")
        vm.onSubmit()
        XCTAssertNotNil(vm.validationErrors["pulseRate"])
    }

    // MARK: - IR010

    func test_IR010_transportDestinationRequiredWhenTransported() {
        let (vm, _) = makeViewModel()
        vm.onFieldChanged(field: "patientName", value: "John")
        vm.onFieldChanged(field: "chiefComplaint", value: "Pain")
        vm.onDispositionSelected(.transported)
        vm.onSubmit()
        XCTAssertNotNil(vm.validationErrors["transportDestination"])
    }

    // MARK: - IR011

    func test_IR011_addTreatmentAppendsToList() {
        let (vm, _) = makeViewModel()
        vm.onAddTreatment("Oxygen")
        XCTAssertEqual(vm.treatments, ["Oxygen"])
    }

    // MARK: - IR012

    func test_IR012_removeTreatmentRemovesFromList() {
        let (vm, _) = makeViewModel()
        vm.onAddTreatment("Oxygen")
        vm.onAddTreatment("IV")
        vm.onRemoveTreatment(at: 0)
        XCTAssertEqual(vm.treatments, ["IV"])
    }

    // MARK: - IR013

    func test_IR013_addProcedureAppendsToList() {
        let (vm, _) = makeViewModel()
        vm.onAddProcedure("Intubation")
        XCTAssertEqual(vm.procedures, ["Intubation"])
    }

    // MARK: - IR014

    func test_IR014_removeProcedureRemovesFromList() {
        let (vm, _) = makeViewModel()
        vm.onAddProcedure("Intubation")
        vm.onAddProcedure("CPR")
        vm.onRemoveProcedure(at: 0)
        XCTAssertEqual(vm.procedures, ["CPR"])
    }

    // MARK: - IR015

    func test_IR015_timestampTapRecordsCurrentTime() {
        let (vm, _) = makeViewModel()
        XCTAssertNil(vm.arrivalTime)
        vm.onTimestampTapped("arrivalTime")
        XCTAssertNotNil(vm.arrivalTime)
    }

    // MARK: - IR016

    func test_IR016_backWithDirtyFormShowsDiscardConfirmation() {
        let (vm, _) = makeViewModel()
        vm.onFieldChanged(field: "patientName", value: "Jane")
        vm.onBackTapped()
        XCTAssertEqual(vm.effect, .showDiscardConfirmation)
    }

    // MARK: - IR017

    func test_IR017_backWithCleanFormNavigatesBack() {
        let (vm, _) = makeViewModel()
        vm.onBackTapped()
        XCTAssertEqual(vm.effect, .navigateBack)
    }

    // MARK: - IR018

    func test_IR018_discardConfirmedNavigatesBack() {
        let (vm, _) = makeViewModel()
        vm.onDiscardConfirmed()
        XCTAssertEqual(vm.effect, .navigateBack)
    }

    // MARK: - IR019

    func test_IR019_transportDestinationNotRequiredWhenRefusal() {
        let (vm, _) = makeViewModel()
        vm.onFieldChanged(field: "patientName", value: "John")
        vm.onFieldChanged(field: "chiefComplaint", value: "Pain")
        vm.onDispositionSelected(.refusal)
        vm.onSubmit()
        XCTAssertNil(vm.validationErrors["transportDestination"])
    }
}
