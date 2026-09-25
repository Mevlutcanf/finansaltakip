import Foundation

struct RecurringItemsSummary: Equatable {
    let monthlyExpenses: Money
    let monthlyIncome: Money
    let monthlyNet: Money
}

/// Aktif sürekli gider/gelirlerin aylık eşdeğerini toplar. Yıllık ödemeler
/// 12'ye bölünerek aylık ortalamaya çevrilir, böylece aylık/yıllık kayıtlar
/// karşılaştırılabilir olur.
enum RecurringItemsSummaryService {
    static func summary(from items: [RecurringItem]) -> RecurringItemsSummary {
        let active = items.filter { $0.isActive }

        let expenseMinorUnits = active
            .filter { $0.kind == .expense }
            .reduce(Int64(0)) { $0 + $1.monthlyEquivalent.minorUnits }

        let incomeMinorUnits = active
            .filter { $0.kind == .income }
            .reduce(Int64(0)) { $0 + $1.monthlyEquivalent.minorUnits }

        return RecurringItemsSummary(
            monthlyExpenses: Money(minorUnits: expenseMinorUnits),
            monthlyIncome: Money(minorUnits: incomeMinorUnits),
            monthlyNet: Money(minorUnits: incomeMinorUnits - expenseMinorUnits)
        )
    }
}
