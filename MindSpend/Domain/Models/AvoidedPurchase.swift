import Foundation
import SwiftData

@Model
final class AvoidedPurchase {
    var id: UUID
    var itemName: String
    var amountMinorUnits: Int64
    var currencyCode: String
    var createdAt: Date
    var cooldownStartedAt: Date
    var cooldownExpiresAt: Date
    var emotionRaw: String
    var triggerRaw: String?
    var statusRaw: String
    var note: String?

    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .neutral }
        set { emotionRaw = newValue.rawValue }
    }

    var trigger: SpendingTrigger? {
        get { triggerRaw.flatMap(SpendingTrigger.init(rawValue:)) }
        set { triggerRaw = newValue?.rawValue }
    }

    var status: AvoidedPurchaseStatus {
        get { AvoidedPurchaseStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    var money: Money {
        Money(minorUnits: amountMinorUnits, currencyCode: currencyCode)
    }

    var isCooldownActive: Bool {
        status == .pending && cooldownExpiresAt > .now
    }

    init(
        id: UUID = UUID(),
        itemName: String,
        amountMinorUnits: Int64,
        currencyCode: String = "TRY",
        createdAt: Date = .now,
        cooldownStartedAt: Date = .now,
        cooldownExpiresAt: Date,
        emotion: Emotion,
        trigger: SpendingTrigger? = nil,
        status: AvoidedPurchaseStatus = .pending,
        note: String? = nil
    ) {
        self.id = id
        self.itemName = itemName
        self.amountMinorUnits = amountMinorUnits
        self.currencyCode = currencyCode
        self.createdAt = createdAt
        self.cooldownStartedAt = cooldownStartedAt
        self.cooldownExpiresAt = cooldownExpiresAt
        self.emotionRaw = emotion.rawValue
        self.triggerRaw = trigger?.rawValue
        self.statusRaw = status.rawValue
        self.note = note
    }
}
