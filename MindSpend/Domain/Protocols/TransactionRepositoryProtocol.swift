import Foundation

protocol TransactionRepositoryProtocol {
    func fetchAll() throws -> [Transaction]
    func fetch(from startDate: Date, to endDate: Date) throws -> [Transaction]
    func add(_ transaction: Transaction) throws
    func delete(_ transaction: Transaction) throws
}

protocol AvoidedPurchaseRepositoryProtocol {
    func fetchAll() throws -> [AvoidedPurchase]
    func fetchPending() throws -> [AvoidedPurchase]
    func add(_ item: AvoidedPurchase) throws
    func update(_ item: AvoidedPurchase, status: AvoidedPurchaseStatus) throws
    func delete(_ item: AvoidedPurchase) throws
}

protocol ShieldRuleRepositoryProtocol {
    func fetchAll() throws -> [ShieldRule]
    func add(_ rule: ShieldRule) throws
    func update(_ rule: ShieldRule) throws
    func delete(_ rule: ShieldRule) throws
}

protocol ShieldSessionRepositoryProtocol {
    func fetchActive() throws -> [ShieldSession]
    func add(_ session: ShieldSession) throws
    func update(_ session: ShieldSession, status: ShieldSessionStatus) throws
}
