import Foundation
import SwiftData
import Observation

@Observable
final class DashboardViewModel {
    private(set) var monthlySpend: Money = .zero
    private(set) var avoidedCount: Int = 0
    private(set) var avoidedPotential: Money = .zero
    private(set) var activeShieldSessions: [ShieldSession] = []
    private(set) var recentTransactions: [Transaction] = []
    private(set) var streak: StreakSummary = StreakSummary(noSpendDayStreak: 0, cooldownStreakThisWeek: 0)
    private(set) var isTodayConfirmedNoSpend = false
    private(set) var behavioralMetrics: BehavioralMetrics = .empty

    private let transactionRepository: TransactionRepositoryProtocol
    private let avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol
    private let shieldSessionRepository: ShieldSessionRepositoryProtocol
    private let noSpendDayRepository: NoSpendDayRepositoryProtocol
    private let streakService: StreakService

    init(
        transactionRepository: TransactionRepositoryProtocol,
        avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol,
        shieldSessionRepository: ShieldSessionRepositoryProtocol,
        noSpendDayRepository: NoSpendDayRepositoryProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.avoidedPurchaseRepository = avoidedPurchaseRepository
        self.shieldSessionRepository = shieldSessionRepository
        self.noSpendDayRepository = noSpendDayRepository
        self.streakService = StreakService(
            noSpendDayRepository: noSpendDayRepository,
            avoidedPurchaseRepository: avoidedPurchaseRepository
        )
    }

    func refresh() {
        let calendar = Calendar.current
        let now = Date.now
        guard let monthStart = calendar.dateInterval(of: .month, for: now)?.start else { return }

        do {
            let monthTransactions = try transactionRepository.fetch(from: monthStart, to: now)
            let total = monthTransactions.reduce(Int64(0)) { $0 + $1.amountMinorUnits }
            monthlySpend = Money(minorUnits: total)
            recentTransactions = Array(monthTransactions.prefix(5))

            let allAvoided = try avoidedPurchaseRepository.fetchAll()
            let monthAvoidedAll = allAvoided.filter { $0.createdAt >= monthStart }
            let monthAvoided = monthAvoidedAll.filter { $0.status == .avoided }
            avoidedCount = monthAvoided.count
            let avoidedTotal = monthAvoided.reduce(Int64(0)) { $0 + $1.amountMinorUnits }
            avoidedPotential = Money(minorUnits: avoidedTotal)

            behavioralMetrics = BehavioralMetricsService.compute(
                transactions: monthTransactions,
                avoidedPurchases: monthAvoidedAll
            )

            activeShieldSessions = try shieldSessionRepository.fetchActive()
            isTodayConfirmedNoSpend = try noSpendDayRepository.isTodayConfirmed()
            streak = streakService.summary()
        } catch {
            // Local persistence okuma hatası; kullanıcıya boş durum gösterilir.
            monthlySpend = .zero
            recentTransactions = []
        }
    }

    func confirmNoSpendToday() {
        try? noSpendDayRepository.confirmToday()
        refresh()
    }
}
