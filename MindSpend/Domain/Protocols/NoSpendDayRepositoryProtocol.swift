import Foundation

protocol NoSpendDayRepositoryProtocol {
    func fetchAll() throws -> [NoSpendDay]
    func confirmToday() throws
    func isTodayConfirmed() throws -> Bool
}
