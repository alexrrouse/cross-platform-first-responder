package com.tandem.emt.features.incidentlist

import com.tandem.emt.features.incidentlist.models.IncidentSummary
import kotlinx.coroutines.delay

interface IncidentRepository {
    suspend fun fetchIncidents(): List<IncidentSummary>
}

class IncidentRepositoryImpl : IncidentRepository {
    override suspend fun fetchIncidents(): List<IncidentSummary> {
        delay(500)
        return emptyList()
    }
}

class FakeIncidentRepository : IncidentRepository {
    private var result: Result<List<IncidentSummary>> = Result.success(emptyList())
    var fetchCallCount: Int = 0
        private set

    val wasFetchCalled: Boolean get() = fetchCallCount > 0

    fun setResult(incidents: List<IncidentSummary>) {
        result = Result.success(incidents)
    }

    fun setError(exception: Exception) {
        result = Result.failure(exception)
    }

    override suspend fun fetchIncidents(): List<IncidentSummary> {
        fetchCallCount++
        return result.getOrThrow()
    }
}
