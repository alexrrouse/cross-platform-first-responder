package com.tandem.emt.features.incidentlist.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.LocalHospital
import androidx.compose.material.icons.filled.ReportProblem
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.tandem.emt.features.incidentlist.models.IncidentStatus
import com.tandem.emt.features.incidentlist.models.IncidentSummary
import com.tandem.emt.features.incidentlist.models.IncidentType
import com.tandem.emt.features.incidentlist.models.Priority

@Composable
fun IncidentCard(
    incident: IncidentSummary,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val isHighPriority = incident.priority == Priority.HIGH
    val border = if (isHighPriority) {
        BorderStroke(2.dp, Color.Red)
    } else {
        null
    }

    Card(
        onClick = onClick,
        modifier = modifier
            .fillMaxWidth()
            .testTag("incident_card_${incident.id}")
            .semantics {
                contentDescription = buildString {
                    append("Incident ${incident.caseNumber}, ")
                    append("${incident.type.name} at ${incident.address}, ")
                    append("Status: ${incident.status.name}, ")
                    append("Priority: ${incident.priority.name}, ")
                    append("${incident.assignedUnits.size} units assigned")
                }
            },
        border = border,
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = iconForType(incident.type),
                        contentDescription = incident.type.name,
                        modifier = Modifier.size(24.dp),
                        tint = if (isHighPriority) Color.Red else MaterialTheme.colorScheme.primary
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = incident.caseNumber,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.testTag("case_number")
                    )
                }
                StatusBadge(status = incident.status)
            }

            Spacer(modifier = Modifier.height(8.dp))

            Text(
                text = incident.address,
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.testTag("address")
            )

            Spacer(modifier = Modifier.height(4.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = formatRelativeTime(incident.dispatchTime),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.testTag("dispatch_time")
                )
                Text(
                    text = "${incident.assignedUnits.size} unit${if (incident.assignedUnits.size != 1) "s" else ""}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.testTag("unit_count")
                )
            }
        }
    }
}

@Composable
private fun StatusBadge(status: IncidentStatus) {
    val (backgroundColor, textColor) = when (status) {
        IncidentStatus.DISPATCHED -> Color(0xFFFF9800) to Color.White
        IncidentStatus.EN_ROUTE -> Color(0xFF2196F3) to Color.White
        IncidentStatus.ON_SCENE -> Color(0xFF4CAF50) to Color.White
        IncidentStatus.CLEARED -> Color(0xFF9E9E9E) to Color.White
    }

    Surface(
        color = backgroundColor,
        shape = RoundedCornerShape(12.dp),
        modifier = Modifier.testTag("status_badge")
    ) {
        Text(
            text = status.name.replace("_", " "),
            color = textColor,
            style = MaterialTheme.typography.labelSmall,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
        )
    }
}

private fun iconForType(type: IncidentType): ImageVector {
    return when (type) {
        IncidentType.FIRE -> Icons.Default.LocalFireDepartment
        IncidentType.EMS -> Icons.Default.LocalHospital
        IncidentType.HAZMAT -> Icons.Default.Warning
        IncidentType.RESCUE -> Icons.Default.DirectionsCar
        IncidentType.OTHER -> Icons.Default.ReportProblem
    }
}

private fun formatRelativeTime(epochMillis: Long): String {
    val now = System.currentTimeMillis()
    val diff = now - epochMillis
    val minutes = diff / 60_000
    val hours = minutes / 60

    return when {
        minutes < 1 -> "Just now"
        minutes < 60 -> "${minutes}m ago"
        hours < 24 -> "${hours}h ago"
        else -> "${hours / 24}d ago"
    }
}
