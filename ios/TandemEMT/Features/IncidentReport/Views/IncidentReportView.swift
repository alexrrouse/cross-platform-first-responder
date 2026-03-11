import SwiftUI

struct IncidentReportView: View {
    @StateObject var viewModel: IncidentReportViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showDiscardAlert = false
    @State private var newTreatment = ""
    @State private var newProcedure = ""

    var body: some View {
        Form {
            patientInfoSection
            vitalSignsSection
            treatmentsSection
            dispositionSection
            timestampsSection
            narrativeSection
            submitSection
        }
        .accessibilityIdentifier("report_form")
        .navigationTitle("New Report")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { viewModel.onBackTapped() }) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
        }
        .alert("Discard Changes?", isPresented: $showDiscardAlert) {
            Button("Discard", role: .destructive) { viewModel.onDiscardConfirmed() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
                .accessibilityIdentifier("discard_dialog")
        }
        .onChange(of: viewModel.effect) { _, newEffect in
            guard let effect = newEffect else { return }
            viewModel.effect = nil
            switch effect {
            case .navigateBack:
                dismiss()
            case .showDiscardConfirmation:
                showDiscardAlert = true
            case .showSubmitSuccess:
                break
            case .showSubmitError:
                break
            }
        }
    }

    // MARK: - Sections

    private var patientInfoSection: some View {
        Section {
            TextField("Patient Name *", text: $viewModel.patientName)
                .accessibilityIdentifier("field_patient_name")
                .onChange(of: viewModel.patientName) { _, _ in
                    viewModel.validationErrors.removeValue(forKey: "patientName")
                }
            validationErrorText(for: "patientName")

            TextField("Age", text: $viewModel.patientAge)
                .keyboardType(.numberPad)
                .accessibilityIdentifier("field_patient_age")
                .onChange(of: viewModel.patientAge) { _, _ in
                    viewModel.validationErrors.removeValue(forKey: "patientAge")
                }
            validationErrorText(for: "patientAge")

            TextField("Chief Complaint *", text: $viewModel.chiefComplaint)
                .accessibilityIdentifier("field_chief_complaint")
                .onChange(of: viewModel.chiefComplaint) { _, _ in
                    viewModel.validationErrors.removeValue(forKey: "chiefComplaint")
                }
            validationErrorText(for: "chiefComplaint")
        } header: {
            Text("Patient Information")
                .accessibilityIdentifier("section_patient_info")
        }
    }

    private var vitalSignsSection: some View {
        Section {
            HStack {
                TextField("Pulse", text: $viewModel.pulseRate)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("field_pulse_rate")
                TextField("SpO2", text: $viewModel.spO2)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("field_spo2")
            }
            validationErrorText(for: "pulseRate")
            validationErrorText(for: "spO2")

            HStack {
                TextField("BP Systolic", text: $viewModel.bloodPressureSystolic)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("field_bp_systolic")
                Text("/")
                TextField("BP Diastolic", text: $viewModel.bloodPressureDiastolic)
                    .keyboardType(.numberPad)
                    .accessibilityIdentifier("field_bp_diastolic")
            }
            validationErrorText(for: "bloodPressureSystolic")
            validationErrorText(for: "bloodPressureDiastolic")

            TextField("Respiration Rate", text: $viewModel.respirationRate)
                .keyboardType(.numberPad)
                .accessibilityIdentifier("field_respiration_rate")
            validationErrorText(for: "respirationRate")
        } header: {
            Text("Vital Signs")
                .accessibilityIdentifier("section_vital_signs")
        }
    }

    private var treatmentsSection: some View {
        Section {
            VStack(alignment: .leading) {
                ForEach(Array(viewModel.treatments.enumerated()), id: \.offset) { index, treatment in
                    HStack {
                        Text(treatment)
                        Spacer()
                        Button(action: { viewModel.onRemoveTreatment(at: index) }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.textError)
                        }
                        .accessibilityIdentifier("remove_treatment_\(index)")
                    }
                }
            }
            .accessibilityIdentifier("treatment_list")

            HStack {
                TextField("Add treatment", text: $newTreatment)
                Button(action: {
                    viewModel.onAddTreatment(newTreatment)
                    newTreatment = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.brandPrimary)
                }
                .accessibilityIdentifier("add_treatment_button")
            }

            VStack(alignment: .leading) {
                ForEach(Array(viewModel.procedures.enumerated()), id: \.offset) { index, procedure in
                    HStack {
                        Text(procedure)
                        Spacer()
                        Button(action: { viewModel.onRemoveProcedure(at: index) }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.textError)
                        }
                        .accessibilityIdentifier("remove_procedure_\(index)")
                    }
                }
            }
            .accessibilityIdentifier("procedure_list")

            HStack {
                TextField("Add procedure", text: $newProcedure)
                Button(action: {
                    viewModel.onAddProcedure(newProcedure)
                    newProcedure = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.brandPrimary)
                }
                .accessibilityIdentifier("add_procedure_button")
            }
        } header: {
            Text("Treatments & Procedures")
                .accessibilityIdentifier("section_treatments")
        }
    }

    private var dispositionSection: some View {
        Section {
            Picker("Disposition *", selection: $viewModel.disposition) {
                Text("Select...").tag(nil as Disposition?)
                ForEach(Disposition.allCases, id: \.self) { d in
                    Text(d.displayName).tag(d as Disposition?)
                }
            }
            .accessibilityIdentifier("disposition_picker")
            .onChange(of: viewModel.disposition) { _, newVal in
                if let d = newVal {
                    viewModel.onDispositionSelected(d)
                }
            }
            validationErrorText(for: "disposition")

            if viewModel.disposition == .transported {
                TextField("Transport Destination *", text: $viewModel.transportDestination)
                    .accessibilityIdentifier("field_transport_destination")
                    .onChange(of: viewModel.transportDestination) { _, _ in
                        viewModel.validationErrors.removeValue(forKey: "transportDestination")
                    }
                validationErrorText(for: "transportDestination")
            }
        } header: {
            Text("Disposition")
                .accessibilityIdentifier("section_disposition")
        }
    }

    private var timestampsSection: some View {
        Section {
            timestampRow(label: "Arrival", field: "arrivalTime", value: viewModel.arrivalTime, tag: "timestamp_arrival")
            timestampRow(label: "Patient Contact", field: "patientContactTime", value: viewModel.patientContactTime, tag: "timestamp_patient_contact")
            timestampRow(label: "Transport", field: "transportTime", value: viewModel.transportTime, tag: "timestamp_transport")
        } header: {
            Text("Timestamps")
                .accessibilityIdentifier("section_timestamps")
        }
    }

    private var narrativeSection: some View {
        Section {
            TextEditor(text: $viewModel.narrative)
                .frame(minHeight: 100)
                .accessibilityIdentifier("field_narrative")
                .onChange(of: viewModel.narrative) { _, _ in
                    viewModel.validationErrors.removeValue(forKey: "narrative")
                }
        } header: {
            Text("Narrative")
                .accessibilityIdentifier("section_narrative")
        }
    }

    private var submitSection: some View {
        Section {
            if viewModel.isSubmitting {
                HStack {
                    Spacer()
                    ProgressView()
                        .accessibilityIdentifier("submitting_indicator")
                    Spacer()
                }
            } else {
                Button(action: { viewModel.onSubmit() }) {
                    HStack {
                        Spacer()
                        Text("Submit Report")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .listRowBackground(Color.brandPrimary)
                .accessibilityIdentifier("submit_button")
            }
        }
    }

    // MARK: - Helpers

    private func timestampRow(label: String, field: String, value: Date?, tag: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            if let time = value {
                Text(time, style: .time)
                    .foregroundColor(.textSecondary)
            } else {
                Button("Record Now") {
                    viewModel.onTimestampTapped(field)
                }
                .foregroundColor(.brandPrimary)
            }
        }
        .accessibilityIdentifier(tag)
    }

    @ViewBuilder
    private func validationErrorText(for field: String) -> some View {
        if let error = viewModel.validationErrors[field] {
            Text(error)
                .font(.caption)
                .foregroundColor(.textError)
                .accessibilityIdentifier("validation_error_\(field)")
        }
    }
}
