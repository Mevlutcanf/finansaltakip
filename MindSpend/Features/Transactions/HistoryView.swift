import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    var body: some View {
        List {
            Section {
                NavigationLink("Kaçınılan Alışverişler") {
                    AvoidedPurchasesView()
                }
            }

            Section("İşlemler") {
                if transactions.isEmpty {
                    ContentUnavailableView(
                        "Henüz işlem yok",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Ana sayfadan yeni bir harcama kaydedebilirsin.")
                    )
                } else {
                    ForEach(transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }
            }
        }
        .navigationTitle("Geçmiş")
    }
}
