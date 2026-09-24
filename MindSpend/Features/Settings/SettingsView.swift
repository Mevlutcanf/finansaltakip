import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false

    var body: some View {
        List {
            Section("Gizlilik") {
                NavigationLink("Verilerimi Dışa Aktar") {
                    Text("Export (CSV/JSON) — V1.5")
                }
                Button("Tüm Verileri Sil", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }

            Section("Hakkında") {
                LabeledContent("Sürüm", value: "1.0.0")
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
    }

    private func deleteAllData() {
        try? modelContext.delete(model: Transaction.self)
        try? modelContext.delete(model: AvoidedPurchase.self)
        try? modelContext.delete(model: ShieldRule.self)
        try? modelContext.delete(model: ShieldSession.self)
        try? modelContext.save()
    }
}
