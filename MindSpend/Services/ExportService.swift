import Foundation

/// Rehber madde 34 — Transaction ve AvoidedPurchase kayıtlarını CSV/JSON
/// olarak dışa aktarır. Screen Time token'larının ham değerleri export
/// edilmez.
enum ExportFormat {
    case csv
    case json
}

struct ExportService {
    func export(
        transactions: [Transaction],
        avoidedPurchases: [AvoidedPurchase],
        format: ExportFormat
    ) throws -> URL {
        let data: Data
        let fileExtension: String

        switch format {
        case .csv:
            data = Data(makeCSV(transactions: transactions, avoidedPurchases: avoidedPurchases).utf8)
            fileExtension = "csv"
        case .json:
            data = try makeJSON(transactions: transactions, avoidedPurchases: avoidedPurchases)
            fileExtension = "json"
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("mindspend-export-\(Int(Date.now.timeIntervalSince1970))")
            .appendingPathExtension(fileExtension)
        try data.write(to: url)
        return url
    }

    private func makeCSV(transactions: [Transaction], avoidedPurchases: [AvoidedPurchase]) -> String {
        var lines = ["type,date,amount,currency,category,emotion,trigger,status"]

        for transaction in transactions {
            lines.append([
                "transaction",
                ISO8601DateFormatter().string(from: transaction.date),
                String(transaction.amountMinorUnits),
                transaction.currencyCode,
                transaction.category.rawValue,
                transaction.emotion.rawValue,
                transaction.trigger?.rawValue ?? "",
                ""
            ].joined(separator: ","))
        }

        for item in avoidedPurchases {
            lines.append([
                "avoided_purchase",
                ISO8601DateFormatter().string(from: item.createdAt),
                String(item.amountMinorUnits),
                item.currencyCode,
                "",
                item.emotion.rawValue,
                item.trigger?.rawValue ?? "",
                item.status.rawValue
            ].joined(separator: ","))
        }

        return lines.joined(separator: "\n")
    }

    private func makeJSON(transactions: [Transaction], avoidedPurchases: [AvoidedPurchase]) throws -> Data {
        struct ExportedTransaction: Codable {
            let date: Date
            let amountMinorUnits: Int64
            let currencyCode: String
            let category: String
            let emotion: String
            let trigger: String?
        }
        struct ExportedAvoidedPurchase: Codable {
            let date: Date
            let amountMinorUnits: Int64
            let currencyCode: String
            let emotion: String
            let trigger: String?
            let status: String
        }
        struct ExportPayload: Codable {
            let transactions: [ExportedTransaction]
            let avoidedPurchases: [ExportedAvoidedPurchase]
        }

        let payload = ExportPayload(
            transactions: transactions.map {
                ExportedTransaction(
                    date: $0.date,
                    amountMinorUnits: $0.amountMinorUnits,
                    currencyCode: $0.currencyCode,
                    category: $0.category.rawValue,
                    emotion: $0.emotion.rawValue,
                    trigger: $0.trigger?.rawValue
                )
            },
            avoidedPurchases: avoidedPurchases.map {
                ExportedAvoidedPurchase(
                    date: $0.createdAt,
                    amountMinorUnits: $0.amountMinorUnits,
                    currencyCode: $0.currencyCode,
                    emotion: $0.emotion.rawValue,
                    trigger: $0.trigger?.rawValue,
                    status: $0.status.rawValue
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }
}
