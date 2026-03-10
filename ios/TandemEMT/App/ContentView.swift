import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                IncidentListView()
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
