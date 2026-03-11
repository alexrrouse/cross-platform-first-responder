import SwiftUI

struct IncidentReportRoute: Hashable {}

// MARK: - Dummy Data

private struct DummyIncident: Identifiable {
    let id: String
    let number: String
    let type: String
    let typeColor: Color
    let priority: String
    let priorityColor: Color
    let address: String
    let timestamp: String
    let status: String
    let statusColor: Color
}

private let dummyIncidents = [
    DummyIncident(
        id: "1", number: "INC-2024-0847", type: "EMS", typeColor: .typeEms,
        priority: "HIGH", priorityColor: .priorityHigh,
        address: "1425 Oak Street, Apt 3B", timestamp: "12:34 PM",
        status: "On Scene", statusColor: .statusOnScene
    ),
    DummyIncident(
        id: "2", number: "INC-2024-0846", type: "Fire", typeColor: .typeFire,
        priority: "HIGH", priorityColor: .priorityHigh,
        address: "800 Industrial Blvd", timestamp: "11:52 AM",
        status: "En Route", statusColor: .statusEnRoute
    ),
    DummyIncident(
        id: "3", number: "INC-2024-0845", type: "EMS", typeColor: .typeEms,
        priority: "MED", priorityColor: .priorityMedium,
        address: "2200 Pine Avenue", timestamp: "11:15 AM",
        status: "Dispatched", statusColor: .statusDispatched
    ),
    DummyIncident(
        id: "4", number: "INC-2024-0844", type: "Rescue", typeColor: .typeRescue,
        priority: "LOW", priorityColor: .priorityLow,
        address: "Lake Marion Trail, Mile 4", timestamp: "10:30 AM",
        status: "Cleared", statusColor: .statusCleared
    ),
    DummyIncident(
        id: "5", number: "INC-2024-0843", type: "HazMat", typeColor: .typeHazmat,
        priority: "HIGH", priorityColor: .priorityHigh,
        address: "5500 Chemical Plant Rd", timestamp: "9:45 AM",
        status: "Cleared", statusColor: .statusCleared
    ),
]

// MARK: - Incident Card

private struct IncidentCard: View {
    let incident: DummyIncident

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(incident.number)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text(incident.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(incident.statusColor)
                    .clipShape(Capsule())
            }

            Text(incident.address)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Label(incident.type, systemImage: incident.type == "Fire" ? "flame.fill" : incident.type == "EMS" ? "cross.fill" : incident.type == "HazMat" ? "exclamationmark.triangle.fill" : "person.fill")
                    .font(.caption)
                    .foregroundColor(incident.typeColor)

                Text(incident.priority)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(incident.priorityColor)

                Spacer()

                Text(incident.timestamp)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var incidentPath = NavigationPath()

    var body: some View {
        TabView {
            NavigationStack(path: $incidentPath) {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dummyIncidents) { incident in
                            IncidentCard(incident: incident)
                                .accessibilityIdentifier("incident_card_\(incident.id)")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .background(Color(.secondarySystemBackground))
                .overlay(alignment: .bottomTrailing) {
                    Button(action: {
                        incidentPath.append(IncidentReportRoute())
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.brandPrimary)
                    }
                    .accessibilityIdentifier("new_report_button")
                    .padding()
                }
                .navigationTitle("Incidents")
                .navigationDestination(for: IncidentReportRoute.self) { _ in
                    IncidentReportView(
                        viewModel: IncidentReportViewModel(
                            repository: IncidentReportRepository()
                        )
                    )
                }
            }
            .tabItem {
                Label("Incidents", systemImage: "exclamationmark.triangle")
            }

            NavigationStack {
                Text("Coming Soon")
                    .navigationTitle("Map")
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                Text("Coming Soon")
                    .navigationTitle("Chat")
            }
            .tabItem {
                Label("Chat", systemImage: "message")
            }

            NavigationStack {
                Text("Coming Soon")
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppRouter())
}
