import Foundation
import SwiftData

final class ShieldRuleRepository: ShieldRuleRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() throws -> [ShieldRule] {
        let descriptor = FetchDescriptor<ShieldRule>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try context.fetch(descriptor)
    }

    func add(_ rule: ShieldRule) throws {
        context.insert(rule)
        try context.save()
    }

    func update(_ rule: ShieldRule) throws {
        try context.save()
    }

    func delete(_ rule: ShieldRule) throws {
        context.delete(rule)
        try context.save()
    }
}

final class ShieldSessionRepository: ShieldSessionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchActive() throws -> [ShieldSession] {
        let predicate = #Predicate<ShieldSession> { $0.statusRaw == "active" }
        let descriptor = FetchDescriptor<ShieldSession>(predicate: predicate)
        return try context.fetch(descriptor)
    }

    func add(_ session: ShieldSession) throws {
        context.insert(session)
        try context.save()
    }

    func update(_ session: ShieldSession, status: ShieldSessionStatus) throws {
        session.status = status
        try context.save()
    }
}
