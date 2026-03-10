package com.tandem.emt.ui.theme

import androidx.compose.ui.graphics.Color
import com.tandem.emt.features.incidentlist.models.IncidentStatus
import com.tandem.emt.features.incidentlist.models.IncidentType
import com.tandem.emt.features.incidentlist.models.Priority

fun incidentTypeTint(type: IncidentType): Color = when (type) {
    IncidentType.FIRE -> TypeFire
    IncidentType.EMS -> TypeEms
    IncidentType.HAZMAT -> TypeHazmat
    IncidentType.RESCUE -> TypeRescue
    IncidentType.OTHER -> TypeOther
}

fun statusColor(status: IncidentStatus): Color = when (status) {
    IncidentStatus.DISPATCHED -> StatusDispatched
    IncidentStatus.EN_ROUTE -> StatusEnRoute
    IncidentStatus.ON_SCENE -> StatusOnScene
    IncidentStatus.CLEARED -> StatusCleared
}

fun priorityColor(priority: Priority): Color = when (priority) {
    Priority.HIGH -> PriorityHigh
    Priority.MEDIUM -> PriorityMedium
    Priority.LOW -> PriorityLow
}
