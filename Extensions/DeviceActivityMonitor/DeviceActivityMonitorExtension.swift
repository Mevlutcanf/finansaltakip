import DeviceActivity
import Foundation

/// Cooldown süresinin sonunu takip eder. `intervalDidEnd`, ana app'in
/// `ShieldSession`'ı `expired` olarak işaretlemesi için App Group üzerinden
/// bir işaret bırakır; SwiftData'ya extension içinden doğrudan yazılmaz
/// (rehber madde 12).
final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        var state = SharedShieldState.current
        state.activeSessionId = nil
        state.expiresAt = nil
        SharedShieldState.current = state
    }
}
