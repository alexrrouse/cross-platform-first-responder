package com.tandem.emt.snapshots

import app.cash.paparazzi.DeviceConfig.Companion.PIXEL_6
import app.cash.paparazzi.Paparazzi
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.ui.Modifier
import com.tandem.emt.navigation.IncidentCard
import com.tandem.emt.navigation.dummyIncidents
import com.tandem.emt.ui.theme.DesignTokens
import org.junit.Rule
import org.junit.Test

class IncidentListSnapshotTest {

    @get:Rule
    val paparazzi = Paparazzi(
        deviceConfig = PIXEL_6,
    )

    @OptIn(ExperimentalMaterial3Api::class)
    @Test
    fun incidentListSnapshot() {
        paparazzi.snapshot {
            MaterialTheme {
                Scaffold(
                    topBar = {
                        TopAppBar(title = { Text("Incidents") })
                    }
                ) { padding ->
                    LazyColumn(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(padding),
                        contentPadding = PaddingValues(
                            horizontal = DesignTokens.SpaceLg,
                            vertical = DesignTokens.SpaceSm
                        ),
                        verticalArrangement = Arrangement.spacedBy(DesignTokens.SpaceMd),
                    ) {
                        items(dummyIncidents, key = { it.id }) { incident ->
                            IncidentCard(incident = incident)
                        }
                    }
                }
            }
        }
    }
}
