import Foundation
import FamilyControls
import ManagedSettings
import SwiftData

/// Seçilen uygulama/web sitesi/kategorilere shield uygulayan ve cooldown
/// sürelerini yöneten servis. Ana SwiftUI UI mantığından ayrı tutulur
/// (rehber madde 48) — extension'lar bu sınıfı değil `SharedShieldState`'i
/// okur.
final class ShieldService {
    private let store = ManagedSettingsStore()
    private let sessionRepository: ShieldSessionRepositoryProtocol

    init(sessionRepository: ShieldSessionRepositoryProtocol) {
        self.sessionRepository = sessionRepository
    }

    /// Verilen kural için shield'ı açar ve bir `ShieldSession` başlatır.
    func activateShield(for rule: ShieldRule, duration: CooldownDuration, reason: String?) throws {
        let selection = FamilyActivitySelectionCoding.decode(rule.selectionData)

        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens

        let expiresAt = duration.expirationDate()
        let session = ShieldSession(
            ruleId: rule.id,
            expiresAt: expiresAt,
            reason: reason,
            status: .active
        )
        try sessionRepository.add(session)

        SharedShieldState.current = SharedShieldState(
            activeSessionId: session.id,
            ruleName: rule.name,
            expiresAt: expiresAt,
            reasonMessage: reason
        )
    }

    /// Cooldown süresi dolduğunda veya kullanıcı bilinçli olarak
    /// "Yine de aç" akışını tamamladığında shield'ı kaldırır.
    func deactivateShield(session: ShieldSession) throws {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        try sessionRepository.update(session, status: .expired)
        SharedShieldState.current = SharedShieldState()
    }

    func cancelShield(session: ShieldSession) throws {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil

        try sessionRepository.update(session, status: .cancelled)
        SharedShieldState.current = SharedShieldState()
    }
}
