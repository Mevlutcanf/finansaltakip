import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house")
            }

            NavigationStack {
                InsightsView()
            }
            .tabItem {
                Label("Analiz", systemImage: "chart.pie")
            }

            NavigationStack {
                ShieldSetupView()
            }
            .tabItem {
                Label("Kalkan", systemImage: "shield")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("Geçmiş", systemImage: "clock.arrow.circlepath")
            }
        }
    }
}
