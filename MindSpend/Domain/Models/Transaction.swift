import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amountMinorUnits: Int64
    var currencyCode: String
    var date: Date
    var categoryRaw: String
    var emotionRaw: String
    var triggerRaw: String?
    var note: String?
    var createdAt: Date

    var category: SpendingCategory {
        get { SpendingCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }

    var emotion: Emotion {
        get { Emotion(rawValue: emotionRaw) ?? .neutral }
        set { emotionRaw = newValue.rawValue }
    }

    var trigger: SpendingTrigger? {
        get { triggerRaw.flatMap(SpendingTrigger.init(rawValue:)) }
        set { triggerRaw = newValue?.rawValue }
    }

    var money: Money {
        Money(minorUnits: amountMinorUnits, currencyCode: currencyCode)
    }

    init(
        id: UUID = UUID(),
        amountMinorUnits: Int64,
        currencyCode: String = "TRY",
        date: Date = .now,
        category: SpendingCategory,
        emotion: Emotion,
        trigger: SpendingTrigger? = nil,
        note: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.amountMinorUnits = amountMinorUnits
        self.currencyCode = currencyCode
        self.date = date
        self.categoryRaw = category.rawValue
        self.emotionRaw = emotion.rawValue
        self.triggerRaw = trigger?.rawValue
        self.note = note
        self.createdAt = createdAt
    }
}
