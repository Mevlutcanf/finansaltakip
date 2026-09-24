import Foundation

/// Para tutarlarını yuvarlama hatası olmadan tutmak için minor unit (kuruş) tabanlı yardımcı tip.
struct Money: Equatable, Comparable {
    let minorUnits: Int64
    let currencyCode: String

    init(minorUnits: Int64, currencyCode: String = "TRY") {
        self.minorUnits = minorUnits
        self.currencyCode = currencyCode
    }

    var decimalValue: Decimal {
        Decimal(minorUnits) / 100
    }

    /// Yalnızca grafik (Swift Charts `Plottable`) gibi `Double` gerektiren
    /// yerlerde kullanılır; para hesaplamaları her zaman `minorUnits` üzerinden yapılır.
    var doubleValue: Double {
        Double(minorUnits) / 100
    }

    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: decimalValue as NSDecimalNumber) ?? "\(decimalValue) \(currencyCode)"
    }

    static func < (lhs: Money, rhs: Money) -> Bool {
        precondition(lhs.currencyCode == rhs.currencyCode, "Farklı para birimleri karşılaştırılamaz")
        return lhs.minorUnits < rhs.minorUnits
    }

    static func + (lhs: Money, rhs: Money) -> Money {
        precondition(lhs.currencyCode == rhs.currencyCode, "Farklı para birimleri toplanamaz")
        return Money(minorUnits: lhs.minorUnits + rhs.minorUnits, currencyCode: lhs.currencyCode)
    }

    static let zero = Money(minorUnits: 0)
}
