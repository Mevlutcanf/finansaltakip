import Foundation
import SwiftData

/// Yalnızca kullanıcı açıkça "Bugün harcama yapmadım" dediğinde oluşturulur
/// (rehber madde 24). Veri yokluğundan streak artırılmaz.
@Model
final class NoSpendDay {
    var id: UUID
    var date: Date
    var confirmedAt: Date

    init(id: UUID = UUID(), date: Date = .now, confirmedAt: Date = .now) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.confirmedAt = confirmedAt
    }
}
