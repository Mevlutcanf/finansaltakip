import Foundation
import SwiftData

@Model
final class ShieldSession {
    var id: UUID
    var ruleId: UUID?
    var startedAt: Date
    var expiresAt: Date
    var reason: String?
    var statusRaw: String

    var status: ShieldSessionStatus {
        get { ShieldSessionStatus(rawValue: statusRaw) ?? .active }
        set { statusRaw = newValue.rawValue }
    }

    var isActive: Bool {
        status == .active && expiresAt > .now
    }

    init(
        id: UUID = UUID(),
        ruleId: UUID? = nil,
        startedAt: Date = .now,
        expiresAt: Date,
        reason: String? = nil,
        status: ShieldSessionStatus = .active
    ) {
        self.id = id
        self.ruleId = ruleId
        self.startedAt = startedAt
        self.expiresAt = expiresAt
        self.reason = reason
        self.statusRaw = status.rawValue
    }
}
