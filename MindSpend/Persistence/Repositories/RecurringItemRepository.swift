import Foundation
import SwiftData

final class RecurringItemRepository: RecurringItemRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [RecurringItem] {
        let descriptor = FetchDescriptor<RecurringItem>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func add(_ item: RecurringItem) throws {
        context.insert(item)
        try context.save()
    }

    func setActive(_ item: RecurringItem, isActive: Bool) throws {
        item.isActive = isActive
        try context.save()
    }

    func delete(_ item: RecurringItem) throws {
        context.delete(item)
        try context.save()
    }
}
