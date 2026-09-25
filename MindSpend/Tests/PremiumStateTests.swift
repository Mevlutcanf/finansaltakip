import XCTest
@testable import MindSpend

private final class FakeIAPService: IAPServiceProtocol {
    var stateToReturn: PremiumState = .free
    var offeringsToReturn: [PremiumOffering] = []
    var shouldThrowOnPurchase = false
    var shouldThrowOnRestore = false

    func fetchOfferings() async throws -> [PremiumOffering] { offeringsToReturn }

    func purchase(offeringId: String) async throws -> PremiumState {
        if shouldThrowOnPurchase { throw URLError(.badServerResponse) }
        return stateToReturn
    }

    func restorePurchases() async throws -> PremiumState {
        if shouldThrowOnRestore { throw URLError(.badServerResponse) }
        return stateToReturn
    }

    func currentPremiumState() async -> PremiumState { stateToReturn }
}

final class PremiumStateTests: XCTestCase {
    func testFreeStateIsNotPremium() {
        XCTAssertFalse(PremiumState.free.isPremium)
    }

    func testPremiumStateIsPremiumRegardlessOfExpiration() {
        XCTAssertTrue(PremiumState.premium(expiresAt: nil).isPremium)
        XCTAssertTrue(PremiumState.premium(expiresAt: .now).isPremium)
    }

    func testSubscriptionManagerStartsFreeAndRefreshesFromService() async {
        let service = FakeIAPService()
        service.stateToReturn = .premium(expiresAt: nil)
        let manager = SubscriptionManager(service: service)

        XCTAssertEqual(manager.state, .free)

        await manager.refresh()

        XCTAssertTrue(manager.state.isPremium)
    }

    func testPurchaseFailureKeepsPreviousStateAndSetsErrorMessage() async {
        let service = FakeIAPService()
        service.shouldThrowOnPurchase = true
        let manager = SubscriptionManager(service: service)

        await manager.purchase(offeringId: "premium_monthly")

        XCTAssertEqual(manager.state, .free)
        XCTAssertNotNil(manager.lastErrorMessage)
    }

    func testRestoreSuccessUpdatesStateAndClearsError() async {
        let service = FakeIAPService()
        service.stateToReturn = .premium(expiresAt: nil)
        let manager = SubscriptionManager(service: service)

        await manager.restore()

        XCTAssertTrue(manager.state.isPremium)
        XCTAssertNil(manager.lastErrorMessage)
    }

    func testLocalIAPServiceNeverGrantsPremiumWithoutRealKey() async {
        let service = LocalIAPService()

        let offerings = try? await service.fetchOfferings()
        let current = await service.currentPremiumState()
        let purchased = try? await service.purchase(offeringId: "anything")
        let restored = try? await service.restorePurchases()

        XCTAssertEqual(offerings?.count, 0)
        XCTAssertEqual(current, .free)
        XCTAssertEqual(purchased, .free)
        XCTAssertEqual(restored, .free)
    }
}
