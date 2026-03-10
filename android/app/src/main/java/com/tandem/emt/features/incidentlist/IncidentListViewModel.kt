package com.tandem.emt.features.incidentlist

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.tandem.emt.features.incidentlist.models.FilterStatus
import com.tandem.emt.features.incidentlist.models.IncidentStatus
import com.tandem.emt.features.incidentlist.models.IncidentSummary
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.receiveAsFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

data class IncidentListUiState(
    val isLoading: Boolean = false,
    val incidents: List<IncidentSummary> = emptyList(),
    val error: String? = null,
    val filterStatus: FilterStatus = FilterStatus.ALL,
    val lastUpdated: Long? = null,
    val isOffline: Boolean = false
)

sealed class IncidentListEffect {
    data class NavigateToIncidentDetail(val incidentId: String) : IncidentListEffect()
    data class ShowError(val message: String) : IncidentListEffect()
}

class IncidentListViewModel(
    private val repository: IncidentRepository,
    private val currentUserId: String = ""
) : ViewModel() {

    private val _uiState = MutableStateFlow(IncidentListUiState())
    val uiState: StateFlow<IncidentListUiState> = _uiState.asStateFlow()

    private val _effects = Channel<IncidentListEffect>(Channel.BUFFERED)
    val effects: Flow<IncidentListEffect> = _effects.receiveAsFlow()

    val filteredIncidents: StateFlow<List<IncidentSummary>> = _uiState
        .map { state -> applyFilter(state.incidents, state.filterStatus) }
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    fun loadIncidents() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                val incidents = repository.fetchIncidents()
                val sorted = incidents.sortedByDescending { it.dispatchTime }
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    incidents = sorted,
                    lastUpdated = System.currentTimeMillis()
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    error = e.message ?: "Unknown error"
                )
            }
        }
    }

    fun refresh() {
        loadIncidents()
    }

    fun onFilterChanged(filter: FilterStatus) {
        _uiState.value = _uiState.value.copy(filterStatus = filter)
    }

    fun onIncidentTapped(id: String) {
        viewModelScope.launch {
            _effects.send(IncidentListEffect.NavigateToIncidentDetail(id))
        }
    }

    fun onIncidentUpdated(incident: IncidentSummary) {
        val currentIncidents = _uiState.value.incidents.toMutableList()
        val existingIndex = currentIncidents.indexOfFirst { it.id == incident.id }

        if (incident.status == IncidentStatus.CLEARED) {
            if (existingIndex != -1) {
                currentIncidents.removeAt(existingIndex)
            }
        } else if (existingIndex != -1) {
            currentIncidents[existingIndex] = incident
        } else {
            currentIncidents.add(incident)
        }

        val sorted = currentIncidents.sortedByDescending { it.dispatchTime }
        _uiState.value = _uiState.value.copy(incidents = sorted)
    }

    fun setOffline(isOffline: Boolean, cachedIncidents: List<IncidentSummary>? = null) {
        _uiState.value = _uiState.value.copy(
            isOffline = isOffline,
            incidents = cachedIncidents ?: _uiState.value.incidents
        )
    }

    private fun applyFilter(
        incidents: List<IncidentSummary>,
        filter: FilterStatus
    ): List<IncidentSummary> {
        return when (filter) {
            FilterStatus.ALL -> incidents
            FilterStatus.ACTIVE -> incidents.filter { it.status.isActive }
            FilterStatus.MY_ASSIGNED -> incidents.filter { incident ->
                incident.assignedUnits.any { it.id == currentUserId }
            }
        }
    }
}
