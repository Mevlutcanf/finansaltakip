import Foundation
import Observation

@Observable
final class RoastViewModel {
    private(set) var roastText: String = ""
    private(set) var isLoading = false

    private let roastService: RoastServiceProtocol
    private let transactionRepository: TransactionRepositoryProtocol
    private let avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol

    init(
        roastService: RoastServiceProtocol = LocalRoastService(),
        transactionRepository: TransactionRepositoryProtocol,
        avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol
    ) {
        self.roastService = roastService
        self.transactionRepository = transactionRepository
        self.avoidedPurchaseRepository = avoidedPurchaseRepository
    }

    func generate(tone: RoastTone) async {
        isLoading = true
        defer { isLoading = false }

        let summary = buildSummary()
        roastText = await roastService.generateRoast(summary: summary, tone: tone)
    }

    private func buildSummary() -> RoastInputSummary {
        let calendar = Calendar.current
        let monthStart = calendar.dateInterval(of: .month, for: .now)?.start ?? .now
        let transactions = (try? transactionRepository.fetch(from: monthStart, to: .now)) ?? []
        let avoided = ((try? avoidedPurchaseRepository.fetchAll()) ?? [])
            .filter { $0.status == .avoided && $0.createdAt >= monthStart }

        let categoryTotals = Dictionary(grouping: transactions, by: \.category)
            .mapValues { $0.reduce(Int64(0)) { $0 + $1.amountMinorUnits } }
        let topCategory = categoryTotals.max(by: { $0.value < $1.value })?.key

        let triggerCounts = Dictionary(grouping: transactions.compactMap(\.trigger), by: { $0 })
            .mapValues(\.count)
        let topTriggerEntry = triggerCounts.max(by: { $0.value < $1.value })

        let totalSpend = transactions.reduce(Int64(0)) { $0 + $1.amountMinorUnits }
        let avoidedTotal = avoided.reduce(Int64(0)) { $0 + $1.amountMinorUnits }

        return RoastInputSummary(
            topCategory: topCategory,
            topTrigger: topTriggerEntry?.key,
            triggerOccurrenceCount: topTriggerEntry?.value ?? 0,
            avoidedCount: avoided.count,
            avoidedTotal: Money(minorUnits: avoidedTotal),
            totalSpend: Money(minorUnits: totalSpend)
        )
    }
}
