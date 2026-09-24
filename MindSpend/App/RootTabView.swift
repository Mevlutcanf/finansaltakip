import SwiftUI

struct RootTabView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            mainTabs
        } else {
            OnboardingView {
                NotificationService.shared.requestAuthorizationIfNeeded()
                NotificationService.shared.scheduleWeeklyReflection()
                hasCompletedOnboarding = true
            }
        }
    }

    private var mainTabs: some View {
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
