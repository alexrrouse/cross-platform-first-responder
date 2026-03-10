import Foundation

@MainActor
class IncidentListViewModel: ObservableObject {
    // MARK: - State
    @Published private(set) var isLoading = false
    @Published private(set) var incidents: [IncidentSummary] = []
    @Published private(set) var error: String?
    @Published var filterStatus: FilterStatus = .all
    @Published private(set) var lastUpdated: Date?
    @Published private(set) var isOffline = false

    // MARK: - Effects
    @Published var navigationTarget: String?

    // MARK: - Dependencies
    private let repository: IncidentRepositoryProtocol
    let currentUserId: String

    // MARK: - Computed
    var filteredIncidents: [IncidentSummary] {
        let sorted = incidents.sorted { $0.dispatchTime > $1.dispatchTime }
        switch filterStatus {
        case .all:
            return sorted
        case .active:
            return sorted.filter { $0.status.isActive }
        case .myAssigned:
            return sorted.filter { incident in
                incident.assignedUnits.contains { $0.id == currentUserId }
            }
        }
    }

    // MARK: - Init
    init(repository: IncidentRepositoryProtocol, currentUserId: String = "current-user") {
        self.repository = repository
        self.currentUserId = currentUserId
    }

    // MARK: - Actions
    func loadIncidents() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await repository.fetchIncidents()
            incidents = fetched.sorted { $0.dispatchTime > $1.dispatchTime }
            lastUpdated = Date()
        } catch {
            self.error = error.localizedDescription
            incidents = []
        }
        isLoading = false
    }

    func refresh() async {
        await loadIncidents()
    }

    func onFilterChanged(_ filter: FilterStatus) {
        filterStatus = filter
    }

    func onIncidentTapped(_ id: String) {
        navigationTarget = id
    }

    func onIncidentUpdated(_ incident: IncidentSummary) {
        if let index = incidents.firstIndex(where: { $0.id == incident.id }) {
            if incident.status == .cleared {
                incidents.remove(at: index)
            } else {
                incidents[index] = incident
            }
        } else {
            incidents.append(incident)
        }
        incidents.sort { $0.dispatchTime > $1.dispatchTime }
    }

    func setOffline(_ offline: Bool) {
        isOffline = offline
    }
}
