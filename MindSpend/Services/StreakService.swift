import Foundation

struct StreakSummary {
    let noSpendDayStreak: Int
    let cooldownStreakThisWeek: Int
}

/// Streak hesaplamaları yalnızca kullanıcı onaylı verilere dayanır
/// (rehber madde 24) — veri yokluğu streak artırmaz.
final class StreakService {
    private let noSpendDayRepository: NoSpendDayRepositoryProtocol
    private let avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol

    init(noSpendDayRepository: NoSpendDayRepositoryProtocol, avoidedPurchaseRepository: AvoidedPurchaseRepositoryProtocol) {
        self.noSpendDayRepository = noSpendDayRepository
        self.avoidedPurchaseRepository = avoidedPurchaseRepository
    }

    func summary() -> StreakSummary {
        let noSpendDays = (try? noSpendDayRepository.fetchAll()) ?? []
        let noSpendStreak = Self.consecutiveDayStreak(dates: noSpendDays.map(\.date))

        let avoided = (try? avoidedPurchaseRepository.fetchAll()) ?? []
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
        let cooldownCount = avoided.filter { $0.cooldownStartedAt >= weekStart }.count

        return StreakSummary(noSpendDayStreak: noSpendStreak, cooldownStreakThisWeek: cooldownCount)
    }

    private static func consecutiveDayStreak(dates: [Date]) -> Int {
        let calendar = Calendar.current
        let uniqueDays = Set(dates.map { calendar.startOfDay(for: $0) }).sorted(by: >)
        guard let mostRecent = uniqueDays.first else { return 0 }

        let today = calendar.startOfDay(for: .now)
        guard mostRecent == today || mostRecent == calendar.date(byAdding: .day, value: -1, to: today) else {
            return 0
        }

        var streak = 1
        var cursor = mostRecent
        for day in uniqueDays.dropFirst() {
            guard let expectedPrevious = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            guard day == expectedPrevious else { break }
            streak += 1
            cursor = day
        }
        return streak
    }
}
