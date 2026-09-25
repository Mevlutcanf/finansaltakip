import Foundation

struct BehavioralMetrics: Equatable {
    let impulseCount: Int
    let cooldownsStarted: Int
    let avoidedCount: Int
    let topEmotion: Emotion?
    let topTrigger: SpendingTrigger?

    static let empty = BehavioralMetrics(
        impulseCount: 0,
        cooldownsStarted: 0,
        avoidedCount: 0,
        topEmotion: nil,
        topTrigger: nil
    )
}

/// Dashboard'daki davranışsal özet metriklerini hesaplar. Rehberin ana tezi
/// (madde 2) gereği ana metrik "ne kadar harcadım" değil "neden ve ne sıklıkla
/// dürtü yaşıyorum" olmalıdır — bu servis yalnızca bunu hesaplar, para
/// toplamlarına dokunmaz.
enum BehavioralMetricsService {
    static func compute(transactions: [Transaction], avoidedPurchases: [AvoidedPurchase]) -> BehavioralMetrics {
        let impulseCount = transactions.count + avoidedPurchases.count
        let cooldownsStarted = avoidedPurchases.count
        let avoidedCount = avoidedPurchases.filter { $0.status == .avoided }.count

        var emotionCounts: [Emotion: Int] = [:]
        for transaction in transactions {
            emotionCounts[transaction.emotion, default: 0] += 1
        }
        for item in avoidedPurchases {
            emotionCounts[item.emotion, default: 0] += 1
        }
        let topEmotion = emotionCounts.max { $0.value < $1.value }?.key

        var triggerCounts: [SpendingTrigger: Int] = [:]
        for transaction in transactions {
            if let trigger = transaction.trigger {
                triggerCounts[trigger, default: 0] += 1
            }
        }
        for item in avoidedPurchases {
            if let trigger = item.trigger {
                triggerCounts[trigger, default: 0] += 1
            }
        }
        let topTrigger = triggerCounts.max { $0.value < $1.value }?.key

        return BehavioralMetrics(
            impulseCount: impulseCount,
            cooldownsStarted: cooldownsStarted,
            avoidedCount: avoidedCount,
            topEmotion: topEmotion,
            topTrigger: topTrigger
        )
    }
}
