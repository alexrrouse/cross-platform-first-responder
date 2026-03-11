package com.tandem.emt.features.incidentReport.models

data class IncidentReport(
    val id: String,
    val patientName: String,
    val patientAge: Int?,
    val chiefComplaint: String,
    val vitalSigns: VitalSigns,
    val treatments: List<String>,
    val procedures: List<String>,
    val disposition: Disposition?,
    val transportDestination: String?,
    val narrative: String,
    val timestamps: ReportTimestamps,
    val status: ReportStatus,
    val createdAt: Long,
    val updatedAt: Long
)

data class VitalSigns(
    val pulseRate: Int? = null,
    val bloodPressureSystolic: Int? = null,
    val bloodPressureDiastolic: Int? = null,
    val respirationRate: Int? = null,
    val spO2: Int? = null
)

data class ReportTimestamps(
    val arrivalTime: Long? = null,
    val patientContactTime: Long? = null,
    val transportTime: Long? = null
)

enum class Disposition(val displayName: String) {
    TRANSPORTED("Transported"),
    REFUSAL("Refusal"),
    NO_PATIENT("No Patient"),
    DEAD_ON_ARRIVAL("Dead on Arrival"),
    OTHER("Other")
}

enum class ReportStatus {
    DRAFT,
    SUBMITTED
}
