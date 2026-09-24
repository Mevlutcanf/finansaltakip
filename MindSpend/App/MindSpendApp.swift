import SwiftUI
import SwiftData

@main
struct MindSpendApp: App {
    let modelContainer = PersistenceController.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(modelContainer)
    }
}
