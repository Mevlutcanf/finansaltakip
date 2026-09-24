import Foundation
import SwiftData

final class AvoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [AvoidedPurchase] {
        let descriptor = FetchDescriptor<AvoidedPurchase>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func fetchPending() throws -> [AvoidedPurchase] {
        let predicate = #Predicate<AvoidedPurchase> { $0.statusRaw == "pending" }
        let descriptor = FetchDescriptor<AvoidedPurchase>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.cooldownExpiresAt, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    func add(_ item: AvoidedPurchase) throws {
        context.insert(item)
        try context.save()
    }

    func update(_ item: AvoidedPurchase, status: AvoidedPurchaseStatus) throws {
        item.status = status
        try context.save()
    }

    func delete(_ item: AvoidedPurchase) throws {
        context.delete(item)
        try context.save()
    }
}
