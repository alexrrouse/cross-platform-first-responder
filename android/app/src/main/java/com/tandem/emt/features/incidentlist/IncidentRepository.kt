package com.tandem.emt.features.incidentlist

import com.tandem.emt.features.incidentlist.models.Coordinates
import com.tandem.emt.features.incidentlist.models.IncidentStatus
import com.tandem.emt.features.incidentlist.models.IncidentSummary
import com.tandem.emt.features.incidentlist.models.IncidentType
import com.tandem.emt.features.incidentlist.models.Priority
import com.tandem.emt.features.incidentlist.models.UnitSummary
import kotlinx.coroutines.delay

interface IncidentRepository {
    suspend fun fetchIncidents(): List<IncidentSummary>
}

class IncidentRepositoryImpl : IncidentRepository {
    override suspend fun fetchIncidents(): List<IncidentSummary> {
        delay(500)
        return sampleData()
    }

    companion object {
        fun sampleData(): List<IncidentSummary> {
            val now = System.currentTimeMillis()
            return listOf(
                IncidentSummary(
                    id = "INC-001",
                    caseNumber = "2026-00142",
                    type = IncidentType.FIRE,
                    priority = Priority.HIGH,
                    address = "742 Evergreen Terrace",
                    dispatchTime = now - 180_000,
                    status = IncidentStatus.DISPATCHED,
                    assignedUnits = listOf(
                        UnitSummary("E1", "Engine 1"),
                        UnitSummary("L1", "Ladder 1")
                    ),
                    coordinates = Coordinates(40.7128, -74.0060)
                ),
                IncidentSummary(
                    id = "INC-002",
                    caseNumber = "2026-00141",
                    type = IncidentType.EMS,
                    priority = Priority.HIGH,
                    address = "315 Oak Avenue, Apt 4B",
                    dispatchTime = now - 720_000,
                    status = IncidentStatus.EN_ROUTE,
                    assignedUnits = listOf(
                        UnitSummary("M3", "Medic 3")
                    ),
                    coordinates = Coordinates(40.7580, -73.9855)
                ),
                IncidentSummary(
                    id = "INC-003",
                    caseNumber = "2026-00139",
                    type = IncidentType.HAZMAT,
                    priority = Priority.MEDIUM,
                    address = "1200 Industrial Blvd",
                    dispatchTime = now - 2_400_000,
                    status = IncidentStatus.ON_SCENE,
                    assignedUnits = listOf(
                        UnitSummary("HZ1", "Hazmat 1"),
                        UnitSummary("E4", "Engine 4"),
                        UnitSummary("BC2", "Battalion 2")
                    ),
                    coordinates = Coordinates(40.7282, -73.7949)
                ),
                IncidentSummary(
                    id = "INC-004",
                    caseNumber = "2026-00138",
                    type = IncidentType.RESCUE,
                    priority = Priority.MEDIUM,
                    address = "Highway 101 & Exit 14",
                    dispatchTime = now - 3_600_000,
                    status = IncidentStatus.ON_SCENE,
                    assignedUnits = listOf(
                        UnitSummary("R2", "Rescue 2"),
                        UnitSummary("E7", "Engine 7")
                    ),
                    coordinates = Coordinates(40.6892, -74.0445)
                ),
                IncidentSummary(
                    id = "INC-005",
                    caseNumber = "2026-00137",
                    type = IncidentType.EMS,
                    priority = Priority.LOW,
                    address = "55 Maple Street",
                    dispatchTime = now - 5_400_000,
                    status = IncidentStatus.EN_ROUTE,
                    assignedUnits = listOf(
                        UnitSummary("M1", "Medic 1")
                    ),
                    coordinates = Coordinates(40.7484, -73.9967)
                ),
            )
        }
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
