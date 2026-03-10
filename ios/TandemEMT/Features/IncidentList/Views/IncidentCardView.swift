import SwiftUI

struct IncidentCardView: View {
    let incident: IncidentSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName(for: incident.type))
                    .foregroundColor(iconColor(for: incident.type))
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(incident.priority == .high ? Color.red : Color.clear, lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var statusBadge: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
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

    private var statusColor: Color {
        switch incident.status {
        case .dispatched: return .orange
        case .enRoute: return .blue
        case .onScene: return .green
        case .cleared: return .gray
        }
    }

    private func iconName(for type: IncidentType) -> String {
        switch type {
        case .fire: return "flame"
        case .ems: return "cross.case"
        case .hazmat: return "exclamationmark.triangle"
        case .rescue: return "figure.wave"
        case .other: return "questionmark.circle"
        }
    }

    private func iconColor(for type: IncidentType) -> Color {
        switch type {
        case .fire: return .red
        case .ems: return .blue
        case .hazmat: return .yellow
        case .rescue: return .orange
        case .other: return .gray
        }
    }

    private var accessibilityDescription: String {
        let priorityText = incident.priority == .high ? "High priority. " : ""
        return "\(priorityText)\(incident.caseNumber). \(incident.type.rawValue) incident. \(incident.address). Status: \(statusText). \(incident.assignedUnits.count) units assigned."
    }
}
