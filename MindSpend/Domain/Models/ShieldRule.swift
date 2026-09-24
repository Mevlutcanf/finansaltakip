import Foundation
import SwiftData

/// `selectionData`, `FamilyActivitySelection` (FamilyControls) için Codable encode edilmiş `Data`'dır.
/// Bu model Screen Time framework'lerine doğrudan bağımlı değildir; encode/decode işlemi
/// ScreenTime katmanındaki servis tarafından yapılır (bkz. FAZ 3).
@Model
final class ShieldRule {
    var id: UUID
    var name: String
    var selectionData: Data
    var defaultCooldownMinutes: Int
    var isEnabled: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        selectionData: Data,
        defaultCooldownMinutes: Int = CooldownDuration.oneHour.minutes,
        isEnabled: Bool = true,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.selectionData = selectionData
        self.defaultCooldownMinutes = defaultCooldownMinutes
        self.isEnabled = isEnabled
        self.createdAt = createdAt
    }
}
