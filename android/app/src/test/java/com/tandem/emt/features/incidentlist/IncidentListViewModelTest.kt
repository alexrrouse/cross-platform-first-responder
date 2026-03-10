package com.tandem.emt.features.incidentlist

import com.tandem.emt.features.incidentlist.models.Coordinates
import com.tandem.emt.features.incidentlist.models.FilterStatus
import com.tandem.emt.features.incidentlist.models.IncidentStatus
import com.tandem.emt.features.incidentlist.models.IncidentSummary
import com.tandem.emt.features.incidentlist.models.IncidentType
import com.tandem.emt.features.incidentlist.models.Priority
import com.tandem.emt.features.incidentlist.models.UnitSummary
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.test.UnconfinedTestDispatcher
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
class IncidentListViewModelTest {

    private lateinit var repository: FakeIncidentRepository
    private val testDispatcher = UnconfinedTestDispatcher()

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        repository = FakeIncidentRepository()
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun createViewModel(currentUserId: String = "user1"): IncidentListViewModel {
        return IncidentListViewModel(repository, currentUserId)
    }

    private fun makeIncident(
        id: String = "incident-1",
        status: IncidentStatus = IncidentStatus.DISPATCHED,
        priority: Priority = Priority.MEDIUM,
        dispatchTime: Long = System.currentTimeMillis(),
        assignedUnits: List<UnitSummary> = listOf(UnitSummary("unit1", "Engine 1"))
    ): IncidentSummary {
        return IncidentSummary(
            id = id,
            caseNumber = "CASE-$id",
            type = IncidentType.FIRE,
            priority = priority,
            address = "123 Main St",
            dispatchTime = dispatchTime,
            status = status,
            assignedUnits = assignedUnits,
            coordinates = Coordinates(40.7128, -74.0060)
        )
    }

    // IL001: Initial load fetches incidents and populates state
    @Test
    fun test_IL001_initialLoadFetchesAndPopulatesState() = runTest {
        val incidents = listOf(makeIncident("1"), makeIncident("2"))
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertEquals(2, state.incidents.size)
        assertNull(state.error)
        assertNotNull(state.lastUpdated)
        assertTrue(repository.wasFetchCalled)
    }

    // IL002: Load failure sets error state
    @Test
    fun test_IL002_loadFailureSetsErrorState() = runTest {
        repository.setError(RuntimeException("Network error"))

        val viewModel = createViewModel()
        viewModel.loadIncidents()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertTrue(state.incidents.isEmpty())
        assertEquals("Network error", state.error)
    }

    // IL003: Pull-to-refresh reloads data
    @Test
    fun test_IL003_pullToRefreshReloadsData() = runTest {
        val initialIncidents = listOf(makeIncident("1"))
        repository.setResult(initialIncidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()

        val updatedIncidents = listOf(makeIncident("1"), makeIncident("2"))
        repository.setResult(updatedIncidents)
        viewModel.refresh()

        val state = viewModel.uiState.value
        assertEquals(2, state.incidents.size)
        assertEquals(2, repository.fetchCallCount)
    }

    // IL004: Empty incident list from API
    @Test
    fun test_IL004_emptyIncidentListFromAPI() = runTest {
        repository.setResult(emptyList())

        val viewModel = createViewModel()
        viewModel.loadIncidents()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertTrue(state.incidents.isEmpty())
        assertNull(state.error)
    }

    // IL010: Filter by active incidents
    @Test
    fun test_IL010_filterByActiveIncidents() = runTest {
        val incidents = listOf(
            makeIncident("1", status = IncidentStatus.DISPATCHED),
            makeIncident("2", status = IncidentStatus.CLEARED),
            makeIncident("3", status = IncidentStatus.ON_SCENE)
        )
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()
        viewModel.onFilterChanged(FilterStatus.ACTIVE)

        val filtered = viewModel.filteredIncidents.value
        assertEquals(2, filtered.size)
        assertTrue(filtered.all { it.status.isActive })
    }

    // IL011: Filter by my assigned incidents
    @Test
    fun test_IL011_filterByMyAssignedIncidents() = runTest {
        val incidents = listOf(
            makeIncident("1", assignedUnits = listOf(UnitSummary("user1", "Engine 1"))),
            makeIncident("2", assignedUnits = listOf(UnitSummary("user2", "Engine 2"))),
            makeIncident("3", assignedUnits = listOf(UnitSummary("user1", "Engine 1"), UnitSummary("user3", "Engine 3")))
        )
        repository.setResult(incidents)

        val viewModel = createViewModel(currentUserId = "user1")
        viewModel.loadIncidents()
        viewModel.onFilterChanged(FilterStatus.MY_ASSIGNED)

        val filtered = viewModel.filteredIncidents.value
        assertEquals(2, filtered.size)
        assertTrue(filtered.all { incident ->
            incident.assignedUnits.any { it.id == "user1" }
        })
    }

    // IL012: Filter resets to all
    @Test
    fun test_IL012_filterResetsToAll() = runTest {
        val incidents = listOf(
            makeIncident("1", status = IncidentStatus.DISPATCHED),
            makeIncident("2", status = IncidentStatus.CLEARED)
        )
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()
        viewModel.onFilterChanged(FilterStatus.ACTIVE)
        assertEquals(1, viewModel.filteredIncidents.value.size)

        viewModel.onFilterChanged(FilterStatus.ALL)
        assertEquals(2, viewModel.filteredIncidents.value.size)
    }

    // IL020: WebSocket update adds new incident to list
    @Test
    fun test_IL020_webSocketUpdateAddsNewIncident() = runTest {
        val incidents = listOf(
            makeIncident("1", dispatchTime = 1000),
            makeIncident("2", dispatchTime = 2000),
            makeIncident("3", dispatchTime = 3000)
        )
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()
        assertEquals(3, viewModel.uiState.value.incidents.size)

        val newIncident = makeIncident("4", dispatchTime = 4000)
        viewModel.onIncidentUpdated(newIncident)

        assertEquals(4, viewModel.uiState.value.incidents.size)
        assertEquals("4", viewModel.uiState.value.incidents.first().id)
    }

    // IL021: WebSocket update modifies existing incident
    @Test
    fun test_IL021_webSocketUpdateModifiesExistingIncident() = runTest {
        val incidents = listOf(
            makeIncident("123", status = IncidentStatus.DISPATCHED, dispatchTime = 1000)
        )
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()

        val updated = makeIncident("123", status = IncidentStatus.EN_ROUTE, dispatchTime = 1000)
        viewModel.onIncidentUpdated(updated)

        val incident = viewModel.uiState.value.incidents.find { it.id == "123" }
        assertNotNull(incident)
        assertEquals(IncidentStatus.EN_ROUTE, incident!!.status)
    }

    // IL022: WebSocket update removes cleared incident
    @Test
    fun test_IL022_webSocketUpdateRemovesClearedIncident() = runTest {
        val incidents = listOf(
            makeIncident("123", status = IncidentStatus.DISPATCHED, dispatchTime = 1000)
        )
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()
        assertEquals(1, viewModel.uiState.value.incidents.size)

        val cleared = makeIncident("123", status = IncidentStatus.CLEARED, dispatchTime = 1000)
        viewModel.onIncidentUpdated(cleared)

        assertTrue(viewModel.uiState.value.incidents.isEmpty())
    }

    // IL030: Tapping incident triggers navigation effect
    @Test
    fun test_IL030_tappingIncidentTriggersNavigation() = runTest {
        val viewModel = createViewModel()
        viewModel.onIncidentTapped("123")

        val effect = viewModel.effects.first()
        assertTrue(effect is IncidentListEffect.NavigateToIncidentDetail)
        assertEquals("123", (effect as IncidentListEffect.NavigateToIncidentDetail).incidentId)
    }

    // IL040: Incidents sorted by dispatch time descending
    @Test
    fun test_IL040_incidentsSortedByDispatchTimeDescending() = runTest {
        val incidents = listOf(
            makeIncident("old", dispatchTime = 1000),
            makeIncident("new", dispatchTime = 3000),
            makeIncident("mid", dispatchTime = 2000)
        )
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()

        val sorted = viewModel.uiState.value.incidents
        assertEquals("new", sorted[0].id)
        assertEquals("mid", sorted[1].id)
        assertEquals("old", sorted[2].id)
    }

    // IL041: High priority incidents are distinguished
    @Test
    fun test_IL041_highPriorityIncidentsDistinguished() = runTest {
        val incidents = listOf(
            makeIncident("high", priority = Priority.HIGH, dispatchTime = 2000),
            makeIncident("low", priority = Priority.LOW, dispatchTime = 1000)
        )
        repository.setResult(incidents)

        val viewModel = createViewModel()
        viewModel.loadIncidents()

        val highPriority = viewModel.uiState.value.incidents.find { it.id == "high" }
        val lowPriority = viewModel.uiState.value.incidents.find { it.id == "low" }
        assertNotNull(highPriority)
        assertNotNull(lowPriority)
        assertEquals(Priority.HIGH, highPriority!!.priority)
        assertEquals(Priority.LOW, lowPriority!!.priority)
    }

    // IL060: Offline mode shows cached data with banner
    @Test
    fun test_IL060_offlineModeShowsCachedDataWithBanner() = runTest {
        val cachedIncidents = listOf(makeIncident("cached"))

        val viewModel = createViewModel()
        viewModel.setOffline(isOffline = true, cachedIncidents = cachedIncidents)

        val state = viewModel.uiState.value
        assertTrue(state.isOffline)
        assertEquals(1, state.incidents.size)
        assertEquals("cached", state.incidents.first().id)
    }

    // IL061: Offline mode with no cache shows empty state
    @Test
    fun test_IL061_offlineModeNoCacheShowsEmptyState() = runTest {
        val viewModel = createViewModel()
        viewModel.setOffline(isOffline = true, cachedIncidents = emptyList())

        val state = viewModel.uiState.value
        assertTrue(state.isOffline)
        assertTrue(state.incidents.isEmpty())
    }
}
