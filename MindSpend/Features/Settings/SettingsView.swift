import SwiftUI
import SwiftData
import UIKit

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false
    @State private var exportURL: URL?
    @State private var exportError: String?

    var body: some View {
        List {
            Section("Araçlar") {
                NavigationLink("Abonelikler ve Sürekli Gider/Gelir") {
                    RecurringItemsView()
                }
            }

            Section("Gizlilik") {
                NavigationLink("Gizlilik") {
                    PrivacyView()
                }
                Button("Verilerimi Dışa Aktar (CSV)") { export(format: .csv) }
                Button("Verilerimi Dışa Aktar (JSON)") { export(format: .json) }
                Button("Tüm Verileri Sil", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }

            Section("Hakkında") {
                LabeledContent("Sürüm", value: "1.0.0")
            }

            if let exportError {
                Text(exportError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Ayarlar")
        .confirmationDialog(
            "Tüm veriler kalıcı olarak silinecek. Emin misin?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sil", role: .destructive, action: deleteAllData)
            Button("Vazgeç", role: .cancel) {}
        }
        .sheet(item: Binding(get: { exportURL.map(ShareFileItem.init) }, set: { exportURL = $0?.url })) { item in
            ShareSheet(activityItems: [item.url])
        }
    }

    private func deleteAllData() {
        try? modelContext.delete(model: Transaction.self)
        try? modelContext.delete(model: AvoidedPurchase.self)
        try? modelContext.delete(model: ShieldRule.self)
        try? modelContext.delete(model: ShieldSession.self)
        try? modelContext.delete(model: NoSpendDay.self)
        try? modelContext.delete(model: RecurringItem.self)
        try? modelContext.save()
    }

    private func export(format: ExportFormat) {
        do {
            let transactions = try TransactionRepository(context: modelContext).fetchAll()
            let avoided = try AvoidedPurchaseRepository(context: modelContext).fetchAll()
            exportURL = try ExportService().export(transactions: transactions, avoidedPurchases: avoided, format: format)
            exportError = nil
        } catch {
            exportError = "Export başarısız oldu. Lütfen tekrar dene."
        }
    }
}
