import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: InsightsViewModel?

    var body: some View {
        ScrollView {
            if let viewModel {
                VStack(alignment: .leading, spacing: 24) {
                    section(title: "Duygu → Harcama") {
                        if viewModel.emotionBreakdown.isEmpty {
                            emptyState
                        } else {
                            Chart(viewModel.emotionBreakdown) { item in
                                BarMark(
                                    x: .value("Tutar", item.total.doubleValue),
                                    y: .value("Duygu", item.emotion.displayName)
                                )
                            }
                            .frame(height: CGFloat(viewModel.emotionBreakdown.count) * 40 + 20)
                        }
                    }

                    section(title: "Tetikleyici → Harcama") {
                        if viewModel.triggerBreakdown.isEmpty {
                            emptyState
                        } else {
                            Chart(viewModel.triggerBreakdown) { item in
                                BarMark(
                                    x: .value("Tutar", item.total.doubleValue),
                                    y: .value("Tetikleyici", item.trigger.displayName)
                                )
                            }
                            .frame(height: CGFloat(viewModel.triggerBreakdown.count) * 40 + 20)
                        }
                    }

                    section(title: "Kaçınılan Harcama") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.avoidedCount) alışverişten vazgeçildi")
                            Text("Toplam: \(viewModel.avoidedTotal.formatted)")
                                .font(.title3.bold())
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Analiz")
        .onAppear {
            if viewModel == nil {
                viewModel = InsightsViewModel(
                    transactionRepository: TransactionRepository(context: modelContext),
                    avoidedPurchaseRepository: AvoidedPurchaseRepository(context: modelContext)
                )
            }
            viewModel?.refresh()
        }
    }

    private var emptyState: some View {
        Text("Yeterli veri yok.")
            .foregroundStyle(.secondary)
            .font(.subheadline)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}
