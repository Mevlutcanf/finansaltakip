import Foundation

struct WeeklyChallengeStatus: Equatable {
    let activeDays: Int
    let totalDays: Int
    let isCompleted: Bool
}

/// İlk 7 gün aktivasyon meydan okuması: kullanıcının ilk kullandığı 7 gün
/// içinde kaç farklı günde en az bir davranış (harcama kaydı, ertelenen
/// alışveriş ya da onaylı harcamasız gün) kaydettiğini hesaplar. Pencere
/// kapandıktan sonra Dashboard'da gösterilmemesi için `nil` döner.
enum WeeklyChallengeService {
    static let totalDays = 7

    static func status(
        startDate: Date,
        transactions: [Transaction],
        avoidedPurchases: [AvoidedPurchase],
        noSpendDays: [NoSpendDay],
        now: Date = .now
    ) -> WeeklyChallengeStatus? {
        let calendar = Calendar.current
        let windowStart = calendar.startOfDay(for: startDate)
        guard let windowEnd = calendar.date(byAdding: .day, value: totalDays, to: windowStart) else { return nil }
        guard now < windowEnd else { return nil }

        var activeDays = Set<Date>()
        for transaction in transactions where transaction.date >= windowStart && transaction.date < windowEnd {
            activeDays.insert(calendar.startOfDay(for: transaction.date))
        }
        for item in avoidedPurchases where item.createdAt >= windowStart && item.createdAt < windowEnd {
            activeDays.insert(calendar.startOfDay(for: item.createdAt))
        }
        for noSpendDay in noSpendDays where noSpendDay.date >= windowStart && noSpendDay.date < windowEnd {
            activeDays.insert(calendar.startOfDay(for: noSpendDay.date))
        }

        return WeeklyChallengeStatus(
            activeDays: activeDays.count,
            totalDays: totalDays,
            isCompleted: activeDays.count >= totalDays
        )
    }
}
