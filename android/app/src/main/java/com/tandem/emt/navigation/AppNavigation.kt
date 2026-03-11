package com.tandem.emt.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ChatBubble
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.MedicalServices
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavDestination.Companion.hasRoute
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.tandem.emt.ui.theme.*
import kotlinx.serialization.Serializable

@Serializable object IncidentsRoute
@Serializable object IncidentReportRoute
@Serializable object MapRoute
@Serializable object ChatRoute
@Serializable object SettingsRoute

data class TopLevelRoute<T : Any>(
    val name: String,
    val route: T,
    val icon: ImageVector,
)

val topLevelRoutes = listOf(
    TopLevelRoute("Incidents", IncidentsRoute, Icons.Default.Notifications),
    TopLevelRoute("Map", MapRoute, Icons.Default.Map),
    TopLevelRoute("Chat", ChatRoute, Icons.Default.ChatBubble),
    TopLevelRoute("Settings", SettingsRoute, Icons.Default.Settings),
)

// Dummy data

data class DummyIncident(
    val id: String,
    val number: String,
    val type: String,
    val typeColor: Color,
    val typeIcon: ImageVector,
    val priority: String,
    val priorityColor: Color,
    val address: String,
    val timestamp: String,
    val status: String,
    val statusColor: Color,
)

val dummyIncidents = listOf(
    DummyIncident(
        "1", "INC-2024-0847", "EMS", TypeEms, Icons.Default.MedicalServices,
        "HIGH", PriorityHigh, "1425 Oak Street, Apt 3B", "12:34 PM",
        "On Scene", StatusOnScene
    ),
    DummyIncident(
        "2", "INC-2024-0846", "Fire", TypeFire, Icons.Default.LocalFireDepartment,
        "HIGH", PriorityHigh, "800 Industrial Blvd", "11:52 AM",
        "En Route", StatusEnRoute
    ),
    DummyIncident(
        "3", "INC-2024-0845", "EMS", TypeEms, Icons.Default.MedicalServices,
        "MED", PriorityMedium, "2200 Pine Avenue", "11:15 AM",
        "Dispatched", StatusDispatched
    ),
    DummyIncident(
        "4", "INC-2024-0844", "Rescue", TypeRescue, Icons.Default.Person,
        "LOW", PriorityLow, "Lake Marion Trail, Mile 4", "10:30 AM",
        "Cleared", StatusCleared
    ),
    DummyIncident(
        "5", "INC-2024-0843", "HazMat", TypeHazmat, Icons.Default.Warning,
        "HIGH", PriorityHigh, "5500 Chemical Plant Rd", "9:45 AM",
        "Cleared", StatusCleared
    ),
)

// Incident card

@Composable
fun IncidentCard(incident: DummyIncident, modifier: Modifier = Modifier) {
    Card(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(DesignTokens.CardCornerRadius),
        elevation = CardDefaults.cardElevation(defaultElevation = DesignTokens.CardElevation),
    ) {
        Column(modifier = Modifier.padding(DesignTokens.CardPadding)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Text(
                    incident.number,
                    style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.Bold,
                )
                Text(
                    incident.status,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.SemiBold,
                    color = Color.White,
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(incident.statusColor)
                        .padding(horizontal = 8.dp, vertical = 4.dp),
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                incident.address,
                style = MaterialTheme.typography.bodyMedium,
                color = TextSecondaryLight,
            )
            Spacer(modifier = Modifier.height(8.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    incident.typeIcon,
                    contentDescription = incident.type,
                    tint = incident.typeColor,
                    modifier = Modifier.height(16.dp).width(16.dp),
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    incident.type,
                    style = MaterialTheme.typography.labelSmall,
                    color = incident.typeColor,
                )
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    incident.priority,
                    style = MaterialTheme.typography.labelSmall,
                    fontWeight = FontWeight.Bold,
                    color = incident.priorityColor,
                )
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    incident.timestamp,
                    style = MaterialTheme.typography.labelSmall,
                    color = TextSecondaryLight,
                )
            }
        }
    }
}

// Main navigation

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AppNavigation() {
    val navController = rememberNavController()

    Scaffold(
        bottomBar = {
            NavigationBar {
                val navBackStackEntry by navController.currentBackStackEntryAsState()
                val currentDestination = navBackStackEntry?.destination

                topLevelRoutes.forEach { topLevelRoute ->
                    NavigationBarItem(
                        icon = { Icon(topLevelRoute.icon, contentDescription = topLevelRoute.name) },
                        label = { Text(topLevelRoute.name) },
                        selected = currentDestination?.hierarchy?.any {
                            it.hasRoute(topLevelRoute.route::class)
                        } == true,
                        onClick = {
                            navController.navigate(topLevelRoute.route) {
                                popUpTo(navController.graph.findStartDestination().id) {
                                    saveState = true
                                }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = IncidentsRoute,
            modifier = Modifier.padding(innerPadding)
        ) {
            composable<IncidentsRoute> {
                Scaffold(
                    topBar = {
                        TopAppBar(title = { Text("Incidents") })
                    },
                    floatingActionButton = {
                        FloatingActionButton(
                            onClick = { navController.navigate(IncidentReportRoute) },
                            modifier = Modifier.testTag("new_report_button")
                        ) {
                            Icon(Icons.Default.Add, contentDescription = "New Report")
                        }
                    }
                ) { innerScaffoldPadding ->
                    LazyColumn(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerScaffoldPadding)
                            .testTag("incident_list"),
                        contentPadding = PaddingValues(horizontal = DesignTokens.SpaceLg, vertical = DesignTokens.SpaceSm),
                        verticalArrangement = Arrangement.spacedBy(DesignTokens.SpaceMd),
                    ) {
                        items(dummyIncidents, key = { it.id }) { incident ->
                            IncidentCard(
                                incident = incident,
                                modifier = Modifier.testTag("incident_card_${incident.id}")
                            )
                        }
                    }
                }
            }
            composable<IncidentReportRoute> {
                com.tandem.emt.features.incidentReport.ui.IncidentReportScreen(
                    viewModel = androidx.lifecycle.viewmodel.compose.viewModel {
                        com.tandem.emt.features.incidentReport.IncidentReportViewModel(
                            repository = com.tandem.emt.features.incidentReport.IncidentReportRepositoryImpl()
                        )
                    },
                    onNavigateBack = { navController.popBackStack() }
                )
            }
            composable<MapRoute> { PlaceholderScreen("Map") }
            composable<ChatRoute> { PlaceholderScreen("Chat") }
            composable<SettingsRoute> { PlaceholderScreen("Settings") }
        }
    }
}

@Composable
fun PlaceholderScreen(name: String) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center
    ) {
        Text("Coming Soon")
    }
}
