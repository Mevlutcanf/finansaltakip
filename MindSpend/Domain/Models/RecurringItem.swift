import Foundation
import SwiftData

/// Abonelik gibi sürekli giderler ve (isteğe bağlı) sürekli gelirler.
/// Bilinçli olarak ana davranış döngüsünden (Dürtü → Cooldown → Insights)
/// ayrı, opsiyonel bir araç olarak tutulur — Dashboard'un ana mesajına
/// dahil edilmez, yalnızca kendi ekranından erişilir.
@Model
final class RecurringItem {
    var id: UUID
    var name: String
    var amountMinorUnits: Int64
    var currencyCode: String
    var kindRaw: String
    var cycleRaw: String
    var isActive: Bool
    var createdAt: Date

    var kind: RecurringItemKind {
        get { RecurringItemKind(rawValue: kindRaw) ?? .expense }
        set { kindRaw = newValue.rawValue }
    }

    var cycle: BillingCycle {
        get { BillingCycle(rawValue: cycleRaw) ?? .monthly }
        set { cycleRaw = newValue.rawValue }
    }

    var money: Money {
        Money(minorUnits: amountMinorUnits, currencyCode: currencyCode)
    }

    /// Yıllık ödemeleri aylık ortalamaya çevirir, toplamların karşılaştırılabilir olması için.
    var monthlyEquivalent: Money {
        Money(minorUnits: amountMinorUnits / Int64(cycle.monthsInCycle), currencyCode: currencyCode)
    }

    init(
        id: UUID = UUID(),
        name: String,
        amountMinorUnits: Int64,
        currencyCode: String = "TRY",
        kind: RecurringItemKind,
        cycle: BillingCycle,
        isActive: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.amountMinorUnits = amountMinorUnits
        self.currencyCode = currencyCode
        self.kindRaw = kind.rawValue
        self.cycleRaw = cycle.rawValue
        self.isActive = isActive
        self.createdAt = createdAt
    }
}
