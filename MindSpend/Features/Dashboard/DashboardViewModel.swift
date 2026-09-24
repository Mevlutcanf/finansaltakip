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

    private let transactionRepository: TransactionRepositoryProtocol
    private let avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol
    private let shieldSessionRepository: ShieldSessionRepositoryProtocol

    init(
        transactionRepository: TransactionRepositoryProtocol,
        avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol,
        shieldSessionRepository: ShieldSessionRepositoryProtocol
    ) {
        self.transactionRepository = transactionRepository
        self.avoidedPurchaseRepository = avoidedPurchaseRepository
        self.shieldSessionRepository = shieldSessionRepository
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
            let monthAvoided = allAvoided.filter { $0.status == .avoided && $0.createdAt >= monthStart }
            avoidedCount = monthAvoided.count
            let avoidedTotal = monthAvoided.reduce(Int64(0)) { $0 + $1.amountMinorUnits }
            avoidedPotential = Money(minorUnits: avoidedTotal)

            activeShieldSessions = try shieldSessionRepository.fetchActive()
        } catch {
            // Local persistence okuma hatası; kullanıcıya boş durum gösterilir.
            monthlySpend = .zero
            recentTransactions = []
        }
    }
}
