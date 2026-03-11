package com.tandem.emt.features.incidentReport

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tandem.emt.features.incidentReport.models.Disposition
import com.tandem.emt.features.incidentReport.models.IncidentReport
import com.tandem.emt.features.incidentReport.models.ReportStatus
import com.tandem.emt.features.incidentReport.models.ReportTimestamps
import com.tandem.emt.features.incidentReport.models.VitalSigns
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.UUID

data class IncidentReportUiState(
    val patientName: String = "",
    val patientAge: String = "",
    val chiefComplaint: String = "",

    val pulseRate: String = "",
    val bloodPressureSystolic: String = "",
    val bloodPressureDiastolic: String = "",
    val respirationRate: String = "",
    val spO2: String = "",

    val treatments: List<String> = emptyList(),
    val procedures: List<String> = emptyList(),

    val disposition: Disposition? = null,
    val transportDestination: String = "",

    val narrative: String = "",

    val arrivalTime: Long? = null,
    val patientContactTime: Long? = null,
    val transportTime: Long? = null,

    val isSubmitting: Boolean = false,
    val validationErrors: Map<String, String> = emptyMap(),
    val isSaved: Boolean = false
)

sealed class IncidentReportEffect {
    data object NavigateBack : IncidentReportEffect()
    data object ShowDiscardConfirmation : IncidentReportEffect()
    data object ShowSubmitSuccess : IncidentReportEffect()
    data class ShowSubmitError(val message: String) : IncidentReportEffect()
}

class IncidentReportViewModel(
    private val repository: IncidentReportRepository,
    private val timeProvider: () -> Long = { System.currentTimeMillis() }
) : ViewModel() {

    private val _uiState = MutableStateFlow(IncidentReportUiState())
    val uiState: StateFlow<IncidentReportUiState> = _uiState.asStateFlow()

    private val _effects = Channel<IncidentReportEffect>(Channel.BUFFERED)
    val effects: Flow<IncidentReportEffect> = _effects.receiveAsFlow()

    private val isDirty: Boolean
        get() {
            val s = _uiState.value
            return s.patientName.isNotEmpty() ||
                s.patientAge.isNotEmpty() ||
                s.chiefComplaint.isNotEmpty() ||
                s.pulseRate.isNotEmpty() ||
                s.bloodPressureSystolic.isNotEmpty() ||
                s.bloodPressureDiastolic.isNotEmpty() ||
                s.respirationRate.isNotEmpty() ||
                s.spO2.isNotEmpty() ||
                s.treatments.isNotEmpty() ||
                s.procedures.isNotEmpty() ||
                s.disposition != null ||
                s.transportDestination.isNotEmpty() ||
                s.narrative.isNotEmpty() ||
                s.arrivalTime != null ||
                s.patientContactTime != null ||
                s.transportTime != null
        }

    fun onFieldChanged(field: String, value: String) {
        _uiState.update { state ->
            val updated = when (field) {
                "patientName" -> state.copy(patientName = value)
                "patientAge" -> state.copy(patientAge = value)
                "chiefComplaint" -> state.copy(chiefComplaint = value)
                "pulseRate" -> state.copy(pulseRate = value)
                "bloodPressureSystolic" -> state.copy(bloodPressureSystolic = value)
                "bloodPressureDiastolic" -> state.copy(bloodPressureDiastolic = value)
                "respirationRate" -> state.copy(respirationRate = value)
                "spO2" -> state.copy(spO2 = value)
                "transportDestination" -> state.copy(transportDestination = value)
                "narrative" -> state.copy(narrative = value)
                else -> state
            }
            updated.copy(validationErrors = updated.validationErrors - field)
        }
    }

    fun onAddTreatment(treatment: String) {
        if (treatment.isEmpty()) return
        _uiState.update { it.copy(treatments = it.treatments + treatment) }
    }

    fun onRemoveTreatment(index: Int) {
        _uiState.update { state ->
            if (index in state.treatments.indices) {
                state.copy(treatments = state.treatments.toMutableList().apply { removeAt(index) })
            } else state
        }
    }

    fun onAddProcedure(procedure: String) {
        if (procedure.isEmpty()) return
        _uiState.update { it.copy(procedures = it.procedures + procedure) }
    }

    fun onRemoveProcedure(index: Int) {
        _uiState.update { state ->
            if (index in state.procedures.indices) {
                state.copy(procedures = state.procedures.toMutableList().apply { removeAt(index) })
            } else state
        }
    }

    fun onDispositionSelected(disposition: Disposition) {
        _uiState.update {
            it.copy(
                disposition = disposition,
                validationErrors = it.validationErrors - "disposition"
            )
        }
    }

    fun onTimestampTapped(field: String) {
        val now = timeProvider()
        _uiState.update { state ->
            when (field) {
                "arrivalTime" -> state.copy(arrivalTime = now)
                "patientContactTime" -> state.copy(patientContactTime = now)
                "transportTime" -> state.copy(transportTime = now)
                else -> state
            }
        }
    }

    fun onSubmit() {
        if (!validate()) return

        _uiState.update { it.copy(isSubmitting = true) }

        viewModelScope.launch {
            val report = buildReport()
            repository.submitReport(report)
                .onSuccess {
                    _uiState.update { it.copy(isSubmitting = false) }
                    _effects.send(IncidentReportEffect.ShowSubmitSuccess)
                    _effects.send(IncidentReportEffect.NavigateBack)
                }
                .onFailure { error ->
                    _uiState.update { it.copy(isSubmitting = false) }
                    _effects.send(
                        IncidentReportEffect.ShowSubmitError(
                            error.message ?: "Failed to submit report"
                        )
                    )
                }
        }
    }

    fun onBackTapped() {
        viewModelScope.launch {
            if (isDirty) {
                _effects.send(IncidentReportEffect.ShowDiscardConfirmation)
            } else {
                _effects.send(IncidentReportEffect.NavigateBack)
            }
        }
    }

    fun onDiscardConfirmed() {
        viewModelScope.launch {
            _effects.send(IncidentReportEffect.NavigateBack)
        }
    }

    private fun validate(): Boolean {
        val errors = mutableMapOf<String, String>()
        val state = _uiState.value

        if (state.patientName.isBlank()) {
            errors["patientName"] = "Patient name is required"
        }
        if (state.chiefComplaint.isBlank()) {
            errors["chiefComplaint"] = "Chief complaint is required"
        }
        if (state.disposition == null) {
            errors["disposition"] = "Disposition is required"
        }
        if (state.patientAge.isNotEmpty()) {
            val age = state.patientAge.toIntOrNull()
            if (age == null || age < 0 || age > 150) {
                errors["patientAge"] = "Age must be 0–150"
            }
        }
        if (state.pulseRate.isNotEmpty()) {
            val v = state.pulseRate.toIntOrNull()
            if (v == null || v < 0 || v > 300) {
                errors["pulseRate"] = "Pulse must be 0–300"
            }
        }
        if (state.bloodPressureSystolic.isNotEmpty()) {
            val v = state.bloodPressureSystolic.toIntOrNull()
            if (v == null || v < 0 || v > 300) {
                errors["bloodPressureSystolic"] = "Systolic must be 0–300"
            }
        }
        if (state.bloodPressureDiastolic.isNotEmpty()) {
            val v = state.bloodPressureDiastolic.toIntOrNull()
            if (v == null || v < 0 || v > 200) {
                errors["bloodPressureDiastolic"] = "Diastolic must be 0–200"
            }
        }
        if (state.respirationRate.isNotEmpty()) {
            val v = state.respirationRate.toIntOrNull()
            if (v == null || v < 0 || v > 100) {
                errors["respirationRate"] = "Respiration must be 0–100"
            }
        }
        if (state.spO2.isNotEmpty()) {
            val v = state.spO2.toIntOrNull()
            if (v == null || v < 0 || v > 100) {
                errors["spO2"] = "SpO2 must be 0–100"
            }
        }
        if (state.disposition == Disposition.TRANSPORTED && state.transportDestination.isBlank()) {
            errors["transportDestination"] = "Transport destination is required"
        }

        _uiState.update { it.copy(validationErrors = errors) }
        return errors.isEmpty()
    }

    private fun buildReport(): IncidentReport {
        val state = _uiState.value
        val now = timeProvider()
        return IncidentReport(
            id = UUID.randomUUID().toString(),
            patientName = state.patientName,
            patientAge = state.patientAge.toIntOrNull(),
            chiefComplaint = state.chiefComplaint,
            vitalSigns = VitalSigns(
                pulseRate = state.pulseRate.toIntOrNull(),
                bloodPressureSystolic = state.bloodPressureSystolic.toIntOrNull(),
                bloodPressureDiastolic = state.bloodPressureDiastolic.toIntOrNull(),
                respirationRate = state.respirationRate.toIntOrNull(),
                spO2 = state.spO2.toIntOrNull()
            ),
            treatments = state.treatments,
            procedures = state.procedures,
            disposition = state.disposition,
            transportDestination = state.transportDestination.ifBlank { null },
            narrative = state.narrative,
            timestamps = ReportTimestamps(
                arrivalTime = state.arrivalTime,
                patientContactTime = state.patientContactTime,
                transportTime = state.transportTime
            ),
            status = ReportStatus.DRAFT,
            createdAt = now,
            updatedAt = now
        )
    }
}
