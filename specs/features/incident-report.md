# Feature: Incident Report

## Overview
A form-based screen allowing responders to fill out and submit a patient care report
after responding to an incident. Single scrollable form with collapsible sections.
Accessible from the Incidents tab via a "New Report" button.

## User Stories
- As a responder, I want to fill out a patient care report after responding to an incident
- As a responder, I want the form to validate required fields before submission
- As a responder, I want clear feedback when my report is submitted successfully

## State Definition
```
State {
  patientName: String              // default ""
  patientAge: String               // default ""
  chiefComplaint: String           // default ""

  pulseRate: String                // default ""
  bloodPressureSystolic: String    // default ""
  bloodPressureDiastolic: String   // default ""
  respirationRate: String          // default ""
  spO2: String                     // default ""

  treatments: List<String>         // default []
  procedures: List<String>         // default []

  disposition: Disposition?        // default null
  transportDestination: String     // default ""

  narrative: String                // default ""

  arrivalTime: Timestamp?          // default null
  patientContactTime: Timestamp?   // default null
  transportTime: Timestamp?        // default null

  isSubmitting: Boolean            // default false
  validationErrors: Map<String, String>  // field name -> error message
  isSaved: Boolean                 // default false
}

Event {
  OnFieldChanged(fieldName, value)
  OnAddTreatment(treatment)
  OnRemoveTreatment(index)
  OnAddProcedure(procedure)
  OnRemoveProcedure(index)
  OnDispositionSelected(Disposition)
  OnTimestampTapped(fieldName)
  OnSubmit
  OnBackTapped
  OnDiscardConfirmed
}

Effect {
  NavigateBack
  ShowDiscardConfirmation
  ShowSubmitSuccess
  ShowSubmitError(message)
}
```

## Data Model
```
IncidentReport {
  id: String
  patientName: String
  patientAge: Int?
  chiefComplaint: String
  vitalSigns: VitalSigns
  treatments: List<String>
  procedures: List<String>
  disposition: Disposition?
  transportDestination: String?
  narrative: String
  timestamps: ReportTimestamps
  status: ReportStatus
  createdAt: Timestamp
  updatedAt: Timestamp
}

VitalSigns {
  pulseRate: Int?
  bloodPressureSystolic: Int?
  bloodPressureDiastolic: Int?
  respirationRate: Int?
  spO2: Int?
}

ReportTimestamps {
  arrivalTime: Timestamp?
  patientContactTime: Timestamp?
  transportTime: Timestamp?
}

Disposition: enum { transported, refusal, noPatient, deadOnArrival, other }
ReportStatus: enum { draft, submitted }
```

## Screens
### Incident Report Form Screen
- **Route**: Incidents tab → "New Report" button
- **Layout**: Single scrollable form with sections:
  1. Patient Information (name, age, chief complaint)
  2. Vital Signs (pulse, BP systolic/diastolic, respiration, SpO2)
  3. Treatments & Procedures (dynamic lists with add/remove)
  4. Disposition (picker + conditional transport destination)
  5. Timestamps (arrival, patient contact, transport — tap to record "now")
  6. Narrative (multiline text)
  7. Submit button (bottom)
- **States**:
  - Idle: Form ready for input
  - Submitting: Button disabled + spinner
  - Validation errors: Inline error messages per field
  - Submit success: Navigate back
  - Submit error: Error alert, form data preserved
- **Interactions**:
  - Text input for all fields
  - Picker for disposition
  - Add/remove buttons for treatments and procedures
  - Tap timestamp buttons to record current time
  - Submit button at bottom
  - Back button with dirty-state check

## Business Logic
### Validation Rules (run on submit)
- `patientName` — required (non-empty)
- `chiefComplaint` — required (non-empty)
- `disposition` — required (must select one)
- `patientAge` — if provided, must be 0–150
- `pulseRate` — if provided, must be 0–300
- `bloodPressureSystolic` — if provided, must be 0–300
- `bloodPressureDiastolic` — if provided, must be 0–200
- `respirationRate` — if provided, must be 0–100
- `spO2` — if provided, must be 0–100
- `transportDestination` — required when disposition is `transported`

### Dirty State
Form is "dirty" if any field differs from its initial empty/nil value.
Back navigation on a dirty form shows a discard confirmation dialog.

## API Dependencies
- `POST /api/v1/reports` — Submit a new report (stubbed for now)

## Edge Cases
- Network failure during submit: show error, preserve form data
- Back with unsaved changes: show discard confirmation
- Empty treatments/procedures lists are valid
- Timestamps are optional

## Accessibility
- All form fields have labels for VoiceOver/TalkBack
- Validation errors announced to screen readers
- Section headers act as navigation landmarks
- Submit button state changes announced

## Test Tags
| Tag | Element |
|-----|---------|
| `report_form` | Overall form container |
| `section_patient_info` | Patient info section |
| `section_vital_signs` | Vital signs section |
| `section_treatments` | Treatments & procedures section |
| `section_disposition` | Disposition section |
| `section_timestamps` | Timestamps section |
| `section_narrative` | Narrative section |
| `field_patient_name` | Patient name text field |
| `field_patient_age` | Patient age text field |
| `field_chief_complaint` | Chief complaint text field |
| `field_pulse_rate` | Pulse rate text field |
| `field_bp_systolic` | BP systolic text field |
| `field_bp_diastolic` | BP diastolic text field |
| `field_respiration_rate` | Respiration rate text field |
| `field_spo2` | SpO2 text field |
| `treatment_list` | Treatments list container |
| `add_treatment_button` | Add treatment button |
| `procedure_list` | Procedures list container |
| `add_procedure_button` | Add procedure button |
| `disposition_picker` | Disposition selection |
| `field_transport_destination` | Transport destination field |
| `field_narrative` | Narrative text field |
| `timestamp_arrival` | Arrival time button |
| `timestamp_patient_contact` | Patient contact time button |
| `timestamp_transport` | Transport time button |
| `submit_button` | Submit report button |
| `submitting_indicator` | Submitting spinner |
| `validation_error_{fieldName}` | Validation error per field |
| `discard_dialog` | Discard changes dialog |
| `success_message` | Submit success message |

## Platform-Specific Notes
- iOS: Use `Form` with grouped sections, `.keyboardType(.numberPad)` for numeric fields
- Android: Use `LazyColumn` with section headers, `KeyboardType.Number` for numeric fields
