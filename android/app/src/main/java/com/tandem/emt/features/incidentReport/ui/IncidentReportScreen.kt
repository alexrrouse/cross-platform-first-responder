package com.tandem.emt.features.incidentReport.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.RemoveCircle
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.input.KeyboardType
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.tandem.emt.features.incidentReport.IncidentReportEffect
import com.tandem.emt.features.incidentReport.IncidentReportViewModel
import com.tandem.emt.features.incidentReport.models.Disposition
import androidx.compose.ui.unit.dp
import com.tandem.emt.ui.theme.DesignTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun IncidentReportScreen(
    viewModel: IncidentReportViewModel,
    onNavigateBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var showDiscardDialog by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        viewModel.effects.collect { effect ->
            when (effect) {
                is IncidentReportEffect.NavigateBack -> onNavigateBack()
                is IncidentReportEffect.ShowDiscardConfirmation -> showDiscardDialog = true
                is IncidentReportEffect.ShowSubmitSuccess -> {}
                is IncidentReportEffect.ShowSubmitError -> {}
            }
        }
    }

    if (showDiscardDialog) {
        AlertDialog(
            modifier = Modifier.testTag("discard_dialog"),
            onDismissRequest = { showDiscardDialog = false },
            title = { Text("Discard Changes?") },
            text = { Text("You have unsaved changes. Are you sure you want to discard them?") },
            confirmButton = {
                TextButton(onClick = {
                    showDiscardDialog = false
                    viewModel.onDiscardConfirmed()
                }) { Text("Discard") }
            },
            dismissButton = {
                TextButton(onClick = { showDiscardDialog = false }) { Text("Cancel") }
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("New Report") },
                navigationIcon = {
                    IconButton(onClick = { viewModel.onBackTapped() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .padding(horizontal = DesignTokens.SpaceLg)
                .testTag("report_form"),
            verticalArrangement = Arrangement.spacedBy(DesignTokens.SpaceSm)
        ) {
            // Patient Information
            item {
                SectionHeader("Patient Information", Modifier.testTag("section_patient_info"))
            }
            item {
                OutlinedTextField(
                    value = uiState.patientName,
                    onValueChange = { viewModel.onFieldChanged("patientName", it) },
                    label = { Text("Patient Name *") },
                    modifier = Modifier.fillMaxWidth().testTag("field_patient_name"),
                    isError = uiState.validationErrors.containsKey("patientName"),
                    supportingText = validationErrorText(uiState.validationErrors["patientName"], "patientName")
                )
            }
            item {
                OutlinedTextField(
                    value = uiState.patientAge,
                    onValueChange = { viewModel.onFieldChanged("patientAge", it) },
                    label = { Text("Age") },
                    modifier = Modifier.fillMaxWidth().testTag("field_patient_age"),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    isError = uiState.validationErrors.containsKey("patientAge"),
                    supportingText = validationErrorText(uiState.validationErrors["patientAge"], "patientAge")
                )
            }
            item {
                OutlinedTextField(
                    value = uiState.chiefComplaint,
                    onValueChange = { viewModel.onFieldChanged("chiefComplaint", it) },
                    label = { Text("Chief Complaint *") },
                    modifier = Modifier.fillMaxWidth().testTag("field_chief_complaint"),
                    isError = uiState.validationErrors.containsKey("chiefComplaint"),
                    supportingText = validationErrorText(uiState.validationErrors["chiefComplaint"], "chiefComplaint")
                )
            }

            // Vital Signs
            item {
                Spacer(modifier = Modifier.height(DesignTokens.SpaceMd))
                SectionHeader("Vital Signs", Modifier.testTag("section_vital_signs"))
            }
            item {
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(DesignTokens.SpaceSm)) {
                    OutlinedTextField(
                        value = uiState.pulseRate,
                        onValueChange = { viewModel.onFieldChanged("pulseRate", it) },
                        label = { Text("Pulse") },
                        modifier = Modifier.weight(1f).testTag("field_pulse_rate"),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        isError = uiState.validationErrors.containsKey("pulseRate")
                    )
                    OutlinedTextField(
                        value = uiState.spO2,
                        onValueChange = { viewModel.onFieldChanged("spO2", it) },
                        label = { Text("SpO2") },
                        modifier = Modifier.weight(1f).testTag("field_spo2"),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        isError = uiState.validationErrors.containsKey("spO2")
                    )
                }
            }
            item {
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(DesignTokens.SpaceSm)) {
                    OutlinedTextField(
                        value = uiState.bloodPressureSystolic,
                        onValueChange = { viewModel.onFieldChanged("bloodPressureSystolic", it) },
                        label = { Text("BP Systolic") },
                        modifier = Modifier.weight(1f).testTag("field_bp_systolic"),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        isError = uiState.validationErrors.containsKey("bloodPressureSystolic")
                    )
                    OutlinedTextField(
                        value = uiState.bloodPressureDiastolic,
                        onValueChange = { viewModel.onFieldChanged("bloodPressureDiastolic", it) },
                        label = { Text("BP Diastolic") },
                        modifier = Modifier.weight(1f).testTag("field_bp_diastolic"),
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        isError = uiState.validationErrors.containsKey("bloodPressureDiastolic")
                    )
                }
            }
            item {
                OutlinedTextField(
                    value = uiState.respirationRate,
                    onValueChange = { viewModel.onFieldChanged("respirationRate", it) },
                    label = { Text("Respiration Rate") },
                    modifier = Modifier.fillMaxWidth().testTag("field_respiration_rate"),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    isError = uiState.validationErrors.containsKey("respirationRate")
                )
            }

            // Treatments & Procedures
            item {
                Spacer(modifier = Modifier.height(DesignTokens.SpaceMd))
                SectionHeader("Treatments & Procedures", Modifier.testTag("section_treatments"))
            }
            item {
                DynamicListSection(
                    items = uiState.treatments,
                    listTag = "treatment_list",
                    addButtonTag = "add_treatment_button",
                    removeTagPrefix = "remove_treatment",
                    placeholder = "Add treatment",
                    onAdd = { viewModel.onAddTreatment(it) },
                    onRemove = { viewModel.onRemoveTreatment(it) }
                )
            }
            item {
                DynamicListSection(
                    items = uiState.procedures,
                    listTag = "procedure_list",
                    addButtonTag = "add_procedure_button",
                    removeTagPrefix = "remove_procedure",
                    placeholder = "Add procedure",
                    onAdd = { viewModel.onAddProcedure(it) },
                    onRemove = { viewModel.onRemoveProcedure(it) }
                )
            }

            // Disposition
            item {
                Spacer(modifier = Modifier.height(DesignTokens.SpaceMd))
                SectionHeader("Disposition", Modifier.testTag("section_disposition"))
            }
            item {
                DispositionPicker(
                    selected = uiState.disposition,
                    onSelected = { viewModel.onDispositionSelected(it) },
                    isError = uiState.validationErrors.containsKey("disposition"),
                    errorMessage = uiState.validationErrors["disposition"]
                )
            }
            if (uiState.disposition == Disposition.TRANSPORTED) {
                item {
                    OutlinedTextField(
                        value = uiState.transportDestination,
                        onValueChange = { viewModel.onFieldChanged("transportDestination", it) },
                        label = { Text("Transport Destination *") },
                        modifier = Modifier.fillMaxWidth().testTag("field_transport_destination"),
                        isError = uiState.validationErrors.containsKey("transportDestination"),
                        supportingText = validationErrorText(uiState.validationErrors["transportDestination"], "transportDestination")
                    )
                }
            }

            // Timestamps
            item {
                Spacer(modifier = Modifier.height(DesignTokens.SpaceMd))
                SectionHeader("Timestamps", Modifier.testTag("section_timestamps"))
            }
            item {
                TimestampButton(
                    label = "Arrival",
                    value = uiState.arrivalTime,
                    tag = "timestamp_arrival",
                    onTap = { viewModel.onTimestampTapped("arrivalTime") }
                )
            }
            item {
                TimestampButton(
                    label = "Patient Contact",
                    value = uiState.patientContactTime,
                    tag = "timestamp_patient_contact",
                    onTap = { viewModel.onTimestampTapped("patientContactTime") }
                )
            }
            item {
                TimestampButton(
                    label = "Transport",
                    value = uiState.transportTime,
                    tag = "timestamp_transport",
                    onTap = { viewModel.onTimestampTapped("transportTime") }
                )
            }

            // Narrative
            item {
                Spacer(modifier = Modifier.height(DesignTokens.SpaceMd))
                SectionHeader("Narrative", Modifier.testTag("section_narrative"))
            }
            item {
                OutlinedTextField(
                    value = uiState.narrative,
                    onValueChange = { viewModel.onFieldChanged("narrative", it) },
                    label = { Text("Narrative") },
                    modifier = Modifier.fillMaxWidth().testTag("field_narrative"),
                    minLines = 4
                )
            }

            // Submit
            item {
                Spacer(modifier = Modifier.height(DesignTokens.SpaceXl))
                if (uiState.isSubmitting) {
                    Row(
                        modifier = Modifier.fillMaxWidth().testTag("submitting_indicator"),
                        horizontalArrangement = Arrangement.Center
                    ) {
                        CircularProgressIndicator()
                    }
                } else {
                    Button(
                        onClick = { viewModel.onSubmit() },
                        modifier = Modifier.fillMaxWidth().testTag("submit_button"),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = MaterialTheme.colorScheme.primary
                        )
                    ) {
                        Text("Submit Report")
                    }
                }
                Spacer(modifier = Modifier.height(DesignTokens.Space2xl))
            }
        }
    }
}

private fun validationErrorText(error: String?, fieldName: String = ""): (@Composable () -> Unit)? {
    return if (error != null) {
        {
            Text(
                error,
                color = MaterialTheme.colorScheme.error,
                modifier = if (fieldName.isNotEmpty()) Modifier.testTag("validation_error_$fieldName") else Modifier
            )
        }
    } else null
}
