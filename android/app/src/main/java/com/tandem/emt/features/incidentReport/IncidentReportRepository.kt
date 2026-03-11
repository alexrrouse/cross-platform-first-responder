package com.tandem.emt.features.incidentReport

import com.tandem.emt.features.incidentReport.models.IncidentReport
import com.tandem.emt.features.incidentReport.models.ReportStatus
import kotlinx.coroutines.delay

interface IncidentReportRepository {
    suspend fun submitReport(report: IncidentReport): Result<IncidentReport>
}

class IncidentReportRepositoryImpl : IncidentReportRepository {
    override suspend fun submitReport(report: IncidentReport): Result<IncidentReport> {
        // Stub: simulate network delay and return the report as submitted
        delay(1000)
        return Result.success(
            report.copy(
                status = ReportStatus.SUBMITTED,
                updatedAt = System.currentTimeMillis()
            )
        )
    }
}

class FakeIncidentReportRepository : IncidentReportRepository {
    var submitResult: Result<IncidentReport> = Result.success(
        IncidentReport(
            id = "mock-id",
            patientName = "",
            patientAge = null,
            chiefComplaint = "",
            vitalSigns = com.tandem.emt.features.incidentReport.models.VitalSigns(),
            treatments = emptyList(),
            procedures = emptyList(),
            disposition = null,
            transportDestination = null,
            narrative = "",
            timestamps = com.tandem.emt.features.incidentReport.models.ReportTimestamps(),
            status = ReportStatus.SUBMITTED,
            createdAt = System.currentTimeMillis(),
            updatedAt = System.currentTimeMillis()
        )
    )

    override suspend fun submitReport(report: IncidentReport): Result<IncidentReport> {
        return submitResult
    }
}
