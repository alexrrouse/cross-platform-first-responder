import Foundation

enum IncidentReportEffect: Equatable {
    case navigateBack
    case showDiscardConfirmation
    case showSubmitSuccess
    case showSubmitError(String)
}

@MainActor
final class IncidentReportViewModel: ObservableObject {
    // MARK: - State

    @Published var patientName = ""
    @Published var patientAge = ""
    @Published var chiefComplaint = ""

    @Published var pulseRate = ""
    @Published var bloodPressureSystolic = ""
    @Published var bloodPressureDiastolic = ""
    @Published var respirationRate = ""
    @Published var spO2 = ""

    @Published var treatments: [String] = []
    @Published var procedures: [String] = []

    @Published var disposition: Disposition?
    @Published var transportDestination = ""

    @Published var narrative = ""

    @Published var arrivalTime: Date?
    @Published var patientContactTime: Date?
    @Published var transportTime: Date?

    @Published var isSubmitting = false
    @Published var validationErrors: [String: String] = [:]
    @Published var isSaved = false

    @Published var effect: IncidentReportEffect?

    // MARK: - Dependencies

    private let repository: IncidentReportRepositoryProtocol
    private let dateProvider: () -> Date

    init(
        repository: IncidentReportRepositoryProtocol,
        dateProvider: @escaping () -> Date = { Date() }
    ) {
        self.repository = repository
        self.dateProvider = dateProvider
    }

    // MARK: - Computed

    var isDirty: Bool {
        !patientName.isEmpty ||
        !patientAge.isEmpty ||
        !chiefComplaint.isEmpty ||
        !pulseRate.isEmpty ||
        !bloodPressureSystolic.isEmpty ||
        !bloodPressureDiastolic.isEmpty ||
        !respirationRate.isEmpty ||
        !spO2.isEmpty ||
        !treatments.isEmpty ||
        !procedures.isEmpty ||
        disposition != nil ||
        !transportDestination.isEmpty ||
        !narrative.isEmpty ||
        arrivalTime != nil ||
        patientContactTime != nil ||
        transportTime != nil
    }

    // MARK: - Events

    func onFieldChanged(field: String, value: String) {
        switch field {
        case "patientName": patientName = value
        case "patientAge": patientAge = value
        case "chiefComplaint": chiefComplaint = value
        case "pulseRate": pulseRate = value
        case "bloodPressureSystolic": bloodPressureSystolic = value
        case "bloodPressureDiastolic": bloodPressureDiastolic = value
        case "respirationRate": respirationRate = value
        case "spO2": spO2 = value
        case "transportDestination": transportDestination = value
        case "narrative": narrative = value
        default: break
        }
        validationErrors.removeValue(forKey: field)
    }

    func onAddTreatment(_ treatment: String) {
        guard !treatment.isEmpty else { return }
        treatments.append(treatment)
    }

    func onRemoveTreatment(at index: Int) {
        guard treatments.indices.contains(index) else { return }
        treatments.remove(at: index)
    }

    func onAddProcedure(_ procedure: String) {
        guard !procedure.isEmpty else { return }
        procedures.append(procedure)
    }

    func onRemoveProcedure(at index: Int) {
        guard procedures.indices.contains(index) else { return }
        procedures.remove(at: index)
    }

    func onDispositionSelected(_ newDisposition: Disposition) {
        disposition = newDisposition
        validationErrors.removeValue(forKey: "disposition")
    }

    func onTimestampTapped(_ field: String) {
        let now = dateProvider()
        switch field {
        case "arrivalTime": arrivalTime = now
        case "patientContactTime": patientContactTime = now
        case "transportTime": transportTime = now
        default: break
        }
    }

    func onSubmit() {
        guard validate() else { return }

        isSubmitting = true

        Task {
            do {
                let report = buildReport()
                _ = try await repository.submitReport(report)
                isSubmitting = false
                effect = .showSubmitSuccess
                try? await Task.sleep(nanoseconds: 100_000_000)
                effect = .navigateBack
            } catch {
                isSubmitting = false
                effect = .showSubmitError(error.localizedDescription)
            }
        }
    }

    func onBackTapped() {
        if isDirty {
            effect = .showDiscardConfirmation
        } else {
            effect = .navigateBack
        }
    }

    func onDiscardConfirmed() {
        effect = .navigateBack
    }

    // MARK: - Private

    private func validate() -> Bool {
        var errors: [String: String] = [:]

        if patientName.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["patientName"] = "Patient name is required"
        }
        if chiefComplaint.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["chiefComplaint"] = "Chief complaint is required"
        }
        if disposition == nil {
            errors["disposition"] = "Disposition is required"
        }
        if !patientAge.isEmpty {
            if let age = Int(patientAge), age >= 0, age <= 150 { /* valid */ } else {
                errors["patientAge"] = "Age must be 0–150"
            }
        }
        if !pulseRate.isEmpty {
            if let val = Int(pulseRate), val >= 0, val <= 300 { /* valid */ } else {
                errors["pulseRate"] = "Pulse must be 0–300"
            }
        }
        if !bloodPressureSystolic.isEmpty {
            if let val = Int(bloodPressureSystolic), val >= 0, val <= 300 { /* valid */ } else {
                errors["bloodPressureSystolic"] = "Systolic must be 0–300"
            }
        }
        if !bloodPressureDiastolic.isEmpty {
            if let val = Int(bloodPressureDiastolic), val >= 0, val <= 200 { /* valid */ } else {
                errors["bloodPressureDiastolic"] = "Diastolic must be 0–200"
            }
        }
        if !respirationRate.isEmpty {
            if let val = Int(respirationRate), val >= 0, val <= 100 { /* valid */ } else {
                errors["respirationRate"] = "Respiration must be 0–100"
            }
        }
        if !spO2.isEmpty {
            if let val = Int(spO2), val >= 0, val <= 100 { /* valid */ } else {
                errors["spO2"] = "SpO2 must be 0–100"
            }
        }
        if disposition == .transported && transportDestination.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["transportDestination"] = "Transport destination is required"
        }

        validationErrors = errors
        return errors.isEmpty
    }

    private func buildReport() -> IncidentReport {
        IncidentReport(
            id: UUID().uuidString,
            patientName: patientName,
            patientAge: Int(patientAge),
            chiefComplaint: chiefComplaint,
            vitalSigns: VitalSigns(
                pulseRate: Int(pulseRate),
                bloodPressureSystolic: Int(bloodPressureSystolic),
                bloodPressureDiastolic: Int(bloodPressureDiastolic),
                respirationRate: Int(respirationRate),
                spO2: Int(spO2)
            ),
            treatments: treatments,
            procedures: procedures,
            disposition: disposition,
            transportDestination: transportDestination.isEmpty ? nil : transportDestination,
            narrative: narrative,
            timestamps: ReportTimestamps(
                arrivalTime: arrivalTime,
                patientContactTime: patientContactTime,
                transportTime: transportTime
            ),
            status: .draft,
            createdAt: dateProvider(),
            updatedAt: dateProvider()
        )
    }
}
