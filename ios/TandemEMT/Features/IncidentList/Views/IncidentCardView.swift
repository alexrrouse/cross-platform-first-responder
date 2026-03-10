import SwiftUI

struct IncidentCardView: View {
    let incident: IncidentSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName(for: incident.type))
                    .foregroundColor(.incidentTypeTint(incident.type))
                    .font(.title3)

                Text(incident.caseNumber)
                    .font(.headline)

                Spacer()

                statusBadge
            }

            Text(incident.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)

            HStack {
                Text(incident.dispatchTime, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.caption)
                    Text("\(incident.assignedUnits.count)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(AppTheme.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .fill(Color(.systemBackground))
                .shadow(radius: AppTheme.cardShadowRadius)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(
                    incident.priority == .high ? Color.priorityHigh : Color.clear,
                    lineWidth: AppTheme.cardHighPriorityBorderWidth
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var statusBadge: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, AppTheme.statusBadgeHPadding)
            .padding(.vertical, AppTheme.statusBadgeVPadding)
            .background(Color.statusColor(incident.status).opacity(0.2))
            .foregroundColor(.statusColor(incident.status))
            .clipShape(Capsule())
            .accessibilityLabel("Status: \(statusText)")
    }

    private var statusText: String {
        switch incident.status {
        case .dispatched: return "Dispatched"
        case .enRoute: return "En Route"
        case .onScene: return "On Scene"
        case .cleared: return "Cleared"
        }
    }

    private func iconName(for type: IncidentType) -> String {
        switch type {
        case .fire: return "flame.fill"
        case .ems: return "cross.case.fill"
        case .hazmat: return "exclamationmark.triangle.fill"
        case .rescue: return "figure.wave"
        case .other: return "questionmark.circle.fill"
        }
    }

    private var accessibilityDescription: String {
        let priorityText = incident.priority == .high ? "High priority. " : ""
        return "\(priorityText)\(incident.caseNumber). \(incident.type.rawValue) incident. \(incident.address). Status: \(statusText). \(incident.assignedUnits.count) units assigned."
    }
}
