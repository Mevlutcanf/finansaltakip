import Foundation
import SwiftData

/// Uygulamanın tek `ModelContainer` kaynağı. Migration planı burada büyütülür.
enum PersistenceController {
    static let schema = Schema([
        Transaction.self,
        AvoidedPurchase.self,
        ShieldRule.self,
        ShieldSession.self
    ])

    static func makeContainer(inMemory: Bool = false) -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("ModelContainer oluşturulamadı: \(error)")
        }
    }
}
