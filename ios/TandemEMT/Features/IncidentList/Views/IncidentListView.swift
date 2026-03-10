import SwiftUI

struct IncidentListView: View {
    @StateObject private var viewModel: IncidentListViewModel

    init(repository: IncidentRepositoryProtocol = IncidentRepository(), currentUserId: String = "current-user") {
        _viewModel = StateObject(wrappedValue: IncidentListViewModel(repository: repository, currentUserId: currentUserId))
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isOffline {
                offlineBanner
            }

            filterBar

            Group {
                if viewModel.isLoading && viewModel.incidents.isEmpty {
                    loadingView
                } else if let error = viewModel.error {
                    errorView(message: error)
                } else if viewModel.filteredIncidents.isEmpty {
                    emptyView
                } else {
                    incidentList
                }
            }
        }
        .navigationTitle("Incidents")
        .task {
            await viewModel.loadIncidents()
        }
    }

    // MARK: - Filter Bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterStatus.allCases, id: \.self) { filter in
                    FilterChipView(
                        title: filter.displayName,
                        isSelected: viewModel.filterStatus == filter,
                        action: { viewModel.onFilterChanged(filter) }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Loading
    private var loadingView: some View {
        List {
            ForEach(0..<5, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.brandSecondary.opacity(0.2))
                        .frame(height: 20)
                        .frame(maxWidth: 200)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.brandSecondary.opacity(0.15))
                        .frame(height: 16)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.brandSecondary.opacity(0.1))
                        .frame(height: 14)
                        .frame(maxWidth: 120)
                }
                .padding(.vertical, 8)
                .redacted(reason: .placeholder)
            }
        }
        .listStyle(.plain)
        .accessibilityLabel("Loading incidents")
    }

    // MARK: - Empty
    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.statusCleared)
            Text("No active incidents")
                .font(.title3)
                .foregroundColor(.statusCleared)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Error
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 48))
                .foregroundColor(.priorityHigh)
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry") {
                Task {
                    await viewModel.loadIncidents()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.brandPrimary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Incident List
    private var incidentList: some View {
        List {
            ForEach(viewModel.filteredIncidents) { incident in
                IncidentCardView(incident: incident)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        viewModel.onIncidentTapped(incident.id)
                    }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Offline Banner
    private var offlineBanner: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text("Offline \u{2014} data may be outdated")
                .font(.caption)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.brandAccent.opacity(0.2))
        .foregroundColor(.brandAccent)
    }
}

#Preview {
    NavigationStack {
        IncidentListView()
    }
}
