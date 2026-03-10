import SwiftUI

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.clear)
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.secondary.opacity(0.5), lineWidth: 1)
                )
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityLabel("\(title) filter")
    }
}

#Preview {
    HStack {
        FilterChipView(title: "All", isSelected: true, action: {})
        FilterChipView(title: "Active", isSelected: false, action: {})
    }
    .padding()
}
