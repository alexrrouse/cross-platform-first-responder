package com.tandem.emt.features.incidentlist.ui

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Inbox
import androidx.compose.material.icons.filled.WifiOff
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.tandem.emt.features.incidentlist.IncidentListEffect
import com.tandem.emt.features.incidentlist.IncidentListViewModel
import com.tandem.emt.ui.theme.BrandAccent
import com.tandem.emt.ui.theme.SurfaceBannerLight
import com.tandem.emt.ui.theme.TextSecondaryLight

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun IncidentListScreen(
    viewModel: IncidentListViewModel,
    onIncidentClick: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val filteredIncidents by viewModel.filteredIncidents.collectAsState()

    LaunchedEffect(Unit) {
        viewModel.loadIncidents()
    }

    LaunchedEffect(Unit) {
        viewModel.effects.collect { effect ->
            when (effect) {
                is IncidentListEffect.NavigateToIncidentDetail -> {
                    onIncidentClick(effect.incidentId)
                }
                is IncidentListEffect.ShowError -> { /* handled by UI state */ }
            }
        }
    }

    Column(modifier = Modifier.fillMaxSize()) {
        if (uiState.isOffline) {
            Surface(
                color = SurfaceBannerLight,
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("offline_banner")
            ) {
                Row_OfflineBanner()
            }
        }

        FilterChipBar(
            selectedFilter = uiState.filterStatus,
            onFilterSelected = { viewModel.onFilterChanged(it) },
            modifier = Modifier.padding(vertical = 8.dp)
        )

        PullToRefreshBox(
            isRefreshing = uiState.isLoading && uiState.incidents.isNotEmpty(),
            onRefresh = { viewModel.refresh() },
            modifier = Modifier.fillMaxSize()
        ) {
            when {
                uiState.isLoading && uiState.incidents.isEmpty() -> {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .testTag("loading_indicator"),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }

                uiState.error != null && uiState.incidents.isEmpty() -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .testTag("error_state"),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Text(
                            text = uiState.error ?: "Something went wrong",
                            style = MaterialTheme.typography.bodyLarge,
                            textAlign = TextAlign.Center,
                            modifier = Modifier.testTag("error_message")
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = { viewModel.loadIncidents() },
                            modifier = Modifier.testTag("retry_button")
                        ) {
                            Text("Retry")
                        }
                    }
                }

                filteredIncidents.isEmpty() && !uiState.isLoading -> {
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .testTag("empty_state"),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Inbox,
                            contentDescription = null,
                            modifier = Modifier.size(64.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "No active incidents",
                            style = MaterialTheme.typography.bodyLarge,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.testTag("empty_message")
                        )
                    }
                }

                else -> {
                    LazyColumn(
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp),
                        modifier = Modifier.testTag("incident_list")
                    ) {
                        items(filteredIncidents, key = { it.id }) { incident ->
                            IncidentCard(
                                incident = incident,
                                onClick = { viewModel.onIncidentTapped(incident.id) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun Row_OfflineBanner() {
    androidx.compose.foundation.layout.Row(
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(
            imageVector = Icons.Default.WifiOff,
            contentDescription = "Offline",
            tint = BrandAccent,
            modifier = Modifier.size(20.dp)
        )
        Spacer(modifier = Modifier.size(8.dp))
        Text(
            text = "You are offline. Showing cached data.",
            style = MaterialTheme.typography.bodySmall,
            color = TextSecondaryLight
        )
    }
}
