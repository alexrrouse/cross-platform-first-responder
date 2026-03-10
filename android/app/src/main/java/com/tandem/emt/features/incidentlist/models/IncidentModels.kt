package com.tandem.emt.features.incidentlist.models

enum class IncidentType { FIRE, EMS, HAZMAT, RESCUE, OTHER }

enum class Priority { HIGH, MEDIUM, LOW }

enum class IncidentStatus {
    DISPATCHED, EN_ROUTE, ON_SCENE, CLEARED;

    val isActive: Boolean get() = this != CLEARED
}

data class UnitSummary(val id: String, val name: String)

data class Coordinates(val latitude: Double, val longitude: Double)

data class IncidentSummary(
    val id: String,
    val caseNumber: String,
    val type: IncidentType,
    val priority: Priority,
    val address: String,
    val dispatchTime: Long,
    val status: IncidentStatus,
    val assignedUnits: List<UnitSummary>,
    val coordinates: Coordinates
)

enum class FilterStatus(val displayName: String) {
    ALL("All"),
    ACTIVE("Active"),
    MY_ASSIGNED("My Assigned")
}
