import XCTest
@testable import MindSpend

final class ExportServiceTests: XCTestCase {
    func testCSVExportContainsHeaderAndRow() throws {
        let transaction = Transaction(amountMinorUnits: 1000, category: .food, emotion: .neutral)
        let url = try ExportService().export(transactions: [transaction], avoidedPurchases: [], format: .csv)
        defer { try? FileManager.default.removeItem(at: url) }

        let content = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(content.hasPrefix("type,date,amount"))
        XCTAssertTrue(content.contains("transaction"))
    }

    func testJSONExportIsValid() throws {
        let avoided = AvoidedPurchase(
            itemName: "Test",
            amountMinorUnits: 5000,
            cooldownExpiresAt: .now.addingTimeInterval(3600),
            emotion: .fomo
        )
        let url = try ExportService().export(transactions: [], avoidedPurchases: [avoided], format: .json)
        defer { try? FileManager.default.removeItem(at: url) }

        let data = try Data(contentsOf: url)
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: data))
    }
}
