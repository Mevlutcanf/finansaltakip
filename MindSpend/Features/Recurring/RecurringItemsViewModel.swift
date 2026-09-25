import Foundation
import Observation

@Observable
final class RecurringItemsViewModel {
    private(set) var items: [RecurringItem] = []
    private(set) var summary: RecurringItemsSummary = RecurringItemsSummaryService.summary(from: [])

    private let repository: RecurringItemRepositoryProtocol

    init(repository: RecurringItemRepositoryProtocol) {
        self.repository = repository
    }

    func refresh() {
        items = (try? repository.fetchAll()) ?? []
        summary = RecurringItemsSummaryService.summary(from: items)
    }

    func addItem(name: String, amountMinorUnits: Int64, kind: RecurringItemKind, cycle: BillingCycle) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, amountMinorUnits > 0 else { return }
        let item = RecurringItem(name: trimmedName, amountMinorUnits: amountMinorUnits, kind: kind, cycle: cycle)
        try? repository.add(item)
        refresh()
    }

    func toggleActive(_ item: RecurringItem) {
        try? repository.setActive(item, isActive: !item.isActive)
        refresh()
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            try? repository.delete(items[index])
        }
        refresh()
    }
}
