package com.tandem.emt.features.incidentReport

import com.tandem.emt.features.incidentReport.models.Disposition
import com.tandem.emt.features.incidentReport.models.IncidentReport
import com.tandem.emt.features.incidentReport.models.ReportStatus
import com.tandem.emt.features.incidentReport.models.ReportTimestamps
import com.tandem.emt.features.incidentReport.models.VitalSigns
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class IncidentReportViewModelTest {

    private val testDispatcher = StandardTestDispatcher()

    @Before
    fun setup() {
        Dispatchers.setMain(testDispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun makeViewModel(
        submitResult: Result<IncidentReport> = Result.success(
            IncidentReport(
                id = "mock", patientName = "", patientAge = null, chiefComplaint = "",
                vitalSigns = VitalSigns(), treatments = emptyList(), procedures = emptyList(),
                disposition = null, transportDestination = null, narrative = "",
                timestamps = ReportTimestamps(), status = ReportStatus.SUBMITTED,
                createdAt = 0, updatedAt = 0
            )
        )
    ): Pair<IncidentReportViewModel, FakeIncidentReportRepository> {
        val repo = FakeIncidentReportRepository()
        repo.submitResult = submitResult
        val vm = IncidentReportViewModel(repository = repo, timeProvider = { 1000L })
        return vm to repo
    }

    private fun fillRequiredFields(vm: IncidentReportViewModel) {
        vm.onFieldChanged("patientName", "John Doe")
        vm.onFieldChanged("chiefComplaint", "Chest pain")
        vm.onDispositionSelected(Disposition.REFUSAL)
    }

    // IR001

    @Test
    fun test_IR001_initialStateHasEmptyFields() {
        val (vm, _) = makeViewModel()
        val state = vm.uiState.value
        assertEquals("", state.patientName)
        assertEquals("", state.patientAge)
        assertEquals("", state.chiefComplaint)
        assertEquals("", state.pulseRate)
        assertEquals("", state.bloodPressureSystolic)
        assertEquals("", state.bloodPressureDiastolic)
        assertEquals("", state.respirationRate)
        assertEquals("", state.spO2)
        assertTrue(state.treatments.isEmpty())
        assertTrue(state.procedures.isEmpty())
        assertNull(state.disposition)
        assertEquals("", state.transportDestination)
        assertEquals("", state.narrative)
        assertNull(state.arrivalTime)
        assertNull(state.patientContactTime)
        assertNull(state.transportTime)
        assertFalse(state.isSubmitting)
        assertTrue(state.validationErrors.isEmpty())
        assertFalse(state.isSaved)
    }

    // IR002

    @Test
    fun test_IR002_fieldChangeUpdatesState() {
        val (vm, _) = makeViewModel()
        vm.onFieldChanged("patientName", "John")
        assertEquals("John", vm.uiState.value.patientName)
    }

    // IR003

    @Test
    fun test_IR003_submitWithValidDataSetsSubmitting() = runTest {
        val (vm, _) = makeViewModel()
        fillRequiredFields(vm)
        vm.onSubmit()
        assertTrue(vm.uiState.value.isSubmitting)
        assertTrue(vm.uiState.value.validationErrors.isEmpty())
    }

    // IR004

    @Test
    fun test_IR004_submitSuccessEmitsNavigateBack() = runTest {
        val (vm, _) = makeViewModel()
        fillRequiredFields(vm)

        val effects = mutableListOf<IncidentReportEffect>()
        val job = launch { vm.effects.collect { effects.add(it) } }

        vm.onSubmit()
        advanceUntilIdle()

        assertFalse(vm.uiState.value.isSubmitting)
        assertTrue(effects.any { it is IncidentReportEffect.NavigateBack })
        job.cancel()
    }

    // IR005

    @Test
    fun test_IR005_submitFailureShowsError() = runTest {
        val (vm, _) = makeViewModel(submitResult = Result.failure(RuntimeException("Network error")))
        fillRequiredFields(vm)

        val effects = mutableListOf<IncidentReportEffect>()
        val job = launch { vm.effects.collect { effects.add(it) } }

        vm.onSubmit()
        advanceUntilIdle()

        assertFalse(vm.uiState.value.isSubmitting)
        assertTrue(effects.any { it is IncidentReportEffect.ShowSubmitError })
        job.cancel()
    }

    // IR006

    @Test
    fun test_IR006_submitWithMissingRequiredFieldsSetsValidationErrors() {
        val (vm, _) = makeViewModel()
        vm.onSubmit()
        val errors = vm.uiState.value.validationErrors
        assertNotNull(errors["patientName"])
        assertNotNull(errors["chiefComplaint"])
        assertNotNull(errors["disposition"])
        assertFalse(vm.uiState.value.isSubmitting)
    }

    // IR007

    @Test
    fun test_IR007_validationErrorClearsWhenFieldCorrected() {
        val (vm, _) = makeViewModel()
        vm.onSubmit()
        assertNotNull(vm.uiState.value.validationErrors["patientName"])
        vm.onFieldChanged("patientName", "Jane")
        assertNull(vm.uiState.value.validationErrors["patientName"])
    }

    // IR008

    @Test
    fun test_IR008_patientAgeValidatesRange() {
        val (vm, _) = makeViewModel()
        fillRequiredFields(vm)
        vm.onFieldChanged("patientAge", "200")
        vm.onSubmit()
        assertNotNull(vm.uiState.value.validationErrors["patientAge"])
    }

    // IR009

    @Test
    fun test_IR009_vitalSignsValidateRanges() {
        val (vm, _) = makeViewModel()
        fillRequiredFields(vm)
        vm.onFieldChanged("pulseRate", "999")
        vm.onSubmit()
        assertNotNull(vm.uiState.value.validationErrors["pulseRate"])
    }

    // IR010

    @Test
    fun test_IR010_transportDestinationRequiredWhenTransported() {
        val (vm, _) = makeViewModel()
        vm.onFieldChanged("patientName", "John")
        vm.onFieldChanged("chiefComplaint", "Pain")
        vm.onDispositionSelected(Disposition.TRANSPORTED)
        vm.onSubmit()
        assertNotNull(vm.uiState.value.validationErrors["transportDestination"])
    }

    // IR011

    @Test
    fun test_IR011_addTreatmentAppendsToList() {
        val (vm, _) = makeViewModel()
        vm.onAddTreatment("Oxygen")
        assertEquals(listOf("Oxygen"), vm.uiState.value.treatments)
    }

    // IR012

    @Test
    fun test_IR012_removeTreatmentRemovesFromList() {
        val (vm, _) = makeViewModel()
        vm.onAddTreatment("Oxygen")
        vm.onAddTreatment("IV")
        vm.onRemoveTreatment(0)
        assertEquals(listOf("IV"), vm.uiState.value.treatments)
    }

    // IR013

    @Test
    fun test_IR013_addProcedureAppendsToList() {
        val (vm, _) = makeViewModel()
        vm.onAddProcedure("Intubation")
        assertEquals(listOf("Intubation"), vm.uiState.value.procedures)
    }

    // IR014

    @Test
    fun test_IR014_removeProcedureRemovesFromList() {
        val (vm, _) = makeViewModel()
        vm.onAddProcedure("Intubation")
        vm.onAddProcedure("CPR")
        vm.onRemoveProcedure(0)
        assertEquals(listOf("CPR"), vm.uiState.value.procedures)
    }

    // IR015

    @Test
    fun test_IR015_timestampTapRecordsCurrentTime() {
        val (vm, _) = makeViewModel()
        assertNull(vm.uiState.value.arrivalTime)
        vm.onTimestampTapped("arrivalTime")
        assertNotNull(vm.uiState.value.arrivalTime)
    }

    // IR016

    @Test
    fun test_IR016_backWithDirtyFormShowsDiscardConfirmation() = runTest {
        val (vm, _) = makeViewModel()
        vm.onFieldChanged("patientName", "Jane")

        val effects = mutableListOf<IncidentReportEffect>()
        val job = launch { vm.effects.collect { effects.add(it) } }

        vm.onBackTapped()
        advanceUntilIdle()

        assertTrue(effects.any { it is IncidentReportEffect.ShowDiscardConfirmation })
        job.cancel()
    }

    // IR017

    @Test
    fun test_IR017_backWithCleanFormNavigatesBack() = runTest {
        val (vm, _) = makeViewModel()

        val effects = mutableListOf<IncidentReportEffect>()
        val job = launch { vm.effects.collect { effects.add(it) } }

        vm.onBackTapped()
        advanceUntilIdle()

        assertTrue(effects.any { it is IncidentReportEffect.NavigateBack })
        job.cancel()
    }

    // IR018

    @Test
    fun test_IR018_discardConfirmedNavigatesBack() = runTest {
        val (vm, _) = makeViewModel()

        val effects = mutableListOf<IncidentReportEffect>()
        val job = launch { vm.effects.collect { effects.add(it) } }

        vm.onDiscardConfirmed()
        advanceUntilIdle()

        assertTrue(effects.any { it is IncidentReportEffect.NavigateBack })
        job.cancel()
    }

    // IR019

    @Test
    fun test_IR019_transportDestinationNotRequiredWhenRefusal() {
        val (vm, _) = makeViewModel()
        vm.onFieldChanged("patientName", "John")
        vm.onFieldChanged("chiefComplaint", "Pain")
        vm.onDispositionSelected(Disposition.REFUSAL)
        vm.onSubmit()
        assertNull(vm.uiState.value.validationErrors["transportDestination"])
    }
}
