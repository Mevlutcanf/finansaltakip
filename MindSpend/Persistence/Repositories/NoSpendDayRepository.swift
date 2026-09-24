import Foundation
import SwiftData

final class NoSpendDayRepository: NoSpendDayRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [NoSpendDay] {
        let descriptor = FetchDescriptor<NoSpendDay>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func confirmToday() throws {
        guard try !isTodayConfirmed() else { return }
        context.insert(NoSpendDay())
        try context.save()
    }

    func isTodayConfirmed() throws -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = #Predicate<NoSpendDay> { $0.date == startOfDay }
        let descriptor = FetchDescriptor<NoSpendDay>(predicate: predicate)
        return try !context.fetch(descriptor).isEmpty
    }
}
