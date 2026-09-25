import SwiftUI
import SwiftData
import Charts
import UIKit

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
                                .foregroundStyle(Theme.accent.gradient)
                                .cornerRadius(6)
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
                                .foregroundStyle(Theme.ember.gradient)
                                .cornerRadius(6)
                            }
                            .frame(height: CGFloat(viewModel.triggerBreakdown.count) * 40 + 20)
                        }
                    }

                    section(title: "Kaçınılan Harcama") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(viewModel.avoidedCount) alışverişten vazgeçildi")
                            Text("Toplam: \(viewModel.avoidedTotal.formatted)")
                                .font(.title3.bold())
                                .foregroundStyle(Theme.accent)
                        }
                        .premiumCard()
                    }

                    section(title: "Davranış Döngüsü") {
                        if viewModel.behaviorCycle.allSatisfy({ $0.count == 0 }) {
                            emptyState
                        } else {
                            Chart(viewModel.behaviorCycle) { stage in
                                BarMark(
                                    x: .value("Sayı", stage.count),
                                    y: .value("Aşama", stage.title)
                                )
                                .foregroundStyle(by: .value("Aşama", stage.title))
                            }
                            .frame(height: CGFloat(viewModel.behaviorCycle.count) * 44 + 20)
                            .chartLegend(.hidden)

                            Text("Dürtü kaydettiğinde cooldown başlar; süre dolup karar verildiğinde ve vazgeçtiğinde sayaç ilerler.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
