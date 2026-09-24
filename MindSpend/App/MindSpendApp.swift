import SwiftUI
import SwiftData

@main
struct MindSpendApp: App {
    let modelContainer = PersistenceController.makeContainer()
    @State private var subscriptionManager = SubscriptionManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(subscriptionManager)
                .task { await subscriptionManager.refresh() }
        }
        .modelContainer(modelContainer)
    }
}
