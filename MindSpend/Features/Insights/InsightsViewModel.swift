import Foundation
import SwiftData
import Observation

struct EmotionSpend: Identifiable {
    var id: Emotion { emotion }
    let emotion: Emotion
    let total: Money
}

struct TriggerSpend: Identifiable {
    var id: SpendingTrigger { trigger }
    let trigger: SpendingTrigger
    let total: Money
}

struct CategorySpend: Identifiable {
    var id: SpendingCategory { category }
    let category: SpendingCategory
    let total: Money
}

struct BehaviorCycleStage: Identifiable {
    let id: Int
    let title: String
    let count: Int
}

@Observable
final class InsightsViewModel {
    private(set) var emotionBreakdown: [EmotionSpend] = []
    private(set) var triggerBreakdown: [TriggerSpend] = []
    private(set) var categoryBreakdown: [CategorySpend] = []
    private(set) var avoidedCount: Int = 0
    private(set) var avoidedTotal: Money = .zero
    private(set) var behaviorCycle: [BehaviorCycleStage] = []

    private let transactionRepository: TransactionRepositoryProtocol
    private let avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol

    init(transactionRepository: TransactionRepositoryProtocol, avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol) {
        self.transactionRepository = transactionRepository
        self.avoidedPurchaseRepository = avoidedPurchaseRepository
    }

    func refresh() {
        guard let transactions = try? transactionRepository.fetchAll() else { return }

        var emotionTotals: [Emotion: Int64] = [:]
        var triggerTotals: [SpendingTrigger: Int64] = [:]
        var categoryTotals: [SpendingCategory: Int64] = [:]

        for transaction in transactions {
            emotionTotals[transaction.emotion, default: 0] += transaction.amountMinorUnits
            categoryTotals[transaction.category, default: 0] += transaction.amountMinorUnits
            if let trigger = transaction.trigger {
                triggerTotals[trigger, default: 0] += transaction.amountMinorUnits
            }
        }

        emotionBreakdown = emotionTotals
            .map { EmotionSpend(emotion: $0.key, total: Money(minorUnits: $0.value)) }
            .sorted { $0.total.minorUnits > $1.total.minorUnits }

        triggerBreakdown = triggerTotals
            .map { TriggerSpend(trigger: $0.key, total: Money(minorUnits: $0.value)) }
            .sorted { $0.total.minorUnits > $1.total.minorUnits }

        categoryBreakdown = categoryTotals
            .map { CategorySpend(category: $0.key, total: Money(minorUnits: $0.value)) }
            .sorted { $0.total.minorUnits > $1.total.minorUnits }

        if let avoided = try? avoidedPurchaseRepository.fetchAll() {
            let avoidedOnly = avoided.filter { $0.status == .avoided }
            avoidedCount = avoidedOnly.count
            avoidedTotal = Money(minorUnits: avoidedOnly.reduce(Int64(0)) { $0 + $1.amountMinorUnits })
            behaviorCycle = Self.makeBehaviorCycle(from: avoided)
        }
    }

    /// Rehber madde 23.4 — "Dürtü → Cooldown → Tekrar değerlendirme → Vazgeçildi"
    /// döngüsünü gerçek `AvoidedPurchase` verisinden hesaplar. Uydurma veri
    /// kullanılmaz; her hücre gerçek kayıt sayısıdır.
    static func makeBehaviorCycle(from avoidedPurchases: [AvoidedPurchase]) -> [BehaviorCycleStage] {
        let started = avoidedPurchases.count
        let resolved = avoidedPurchases.filter { $0.status != .pending }.count
        let avoided = avoidedPurchases.filter { $0.status == .avoided }.count

        return [
            BehaviorCycleStage(id: 0, title: "Dürtü Kaydedildi", count: started),
            BehaviorCycleStage(id: 1, title: "Cooldown Tamamlandı", count: resolved),
            BehaviorCycleStage(id: 2, title: "Vazgeçildi", count: avoided)
        ]
    }
}
