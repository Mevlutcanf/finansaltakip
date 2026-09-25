import SwiftUI
import SwiftData
import Charts
import UIKit

private let categoryPalette: [Color] = [
    Theme.accent, Theme.ember, .teal, .pink, .indigo, .mint, .brown
]

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: InsightsViewModel?

    var body: some View {
        ScrollView {
            if let viewModel {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection(viewModel: viewModel)

                    section(title: "Kategoriye Göre Harcama", icon: "chart.pie.fill") {
                        if viewModel.categoryBreakdown.isEmpty {
                            emptyState
                        } else {
                            categoryDonut(viewModel: viewModel)
                        }
                    }

                    section(title: "Duygu → Harcama", icon: "heart.text.square.fill") {
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

                    section(title: "Tetikleyici → Harcama", icon: "bolt.fill") {
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

                    section(title: "Kaçınılan Harcama", icon: "hand.raised.fill") {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(viewModel.avoidedCount) alışverişten vazgeçildi")
                                    .font(.subheadline)
                                Text(viewModel.avoidedTotal.formatted)
                                    .font(.title2.bold())
                                    .foregroundStyle(Theme.accent)
                            }
                            Spacer()
                            Image(systemName: "sparkles")
                                .font(.largeTitle)
                                .foregroundStyle(Theme.accent.opacity(0.3))
                        }
                        .premiumCard()
                    }

                    section(title: "Davranış Döngüsü", icon: "arrow.triangle.2.circlepath") {
                        if viewModel.behaviorCycle.allSatisfy({ $0.count == 0 }) {
                            emptyState
                        } else {
                            Chart(viewModel.behaviorCycle) { stage in
                                BarMark(
                                    x: .value("Sayı", stage.count),
                                    y: .value("Aşama", stage.title)
                                )
                                .foregroundStyle(by: .value("Aşama", stage.title))
                                .cornerRadius(6)
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

    @ViewBuilder
    private func heroSection(viewModel: InsightsViewModel) -> some View {
        let totalSpend = viewModel.categoryBreakdown.reduce(Int64(0)) { $0 + $1.total.minorUnits }
        VStack(alignment: .leading, spacing: 6) {
            Text("Toplam kayıtlı harcama")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
            Text(Money(minorUnits: totalSpend).formatted)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
            Text("Neye, ne zaman ve neden harcadığını görmek davranışını değiştirmenin ilk adımı.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Theme.backgroundGradient, in: RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous))
    }

    @ViewBuilder
    private func categoryDonut(viewModel: InsightsViewModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Chart(Array(viewModel.categoryBreakdown.enumerated()), id: \.element.id) { index, item in
                SectorMark(
                    angle: .value("Tutar", item.total.doubleValue),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(categoryPalette[index % categoryPalette.count])
                .cornerRadius(4)
            }
            .frame(height: 200)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(viewModel.categoryBreakdown.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        Circle()
                            .fill(categoryPalette[index % categoryPalette.count])
                            .frame(width: 10, height: 10)
                        Image(systemName: item.category.symbolName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(item.category.displayName)
                            .font(.subheadline)
                        Spacer()
                        Text(item.total.formatted)
                            .font(.subheadline.weight(.semibold))
                    }
                }
            }
        }
        .premiumCard()
    }

    private var emptyState: some View {
        Text("Yeterli veri yok.")
            .foregroundStyle(.secondary)
            .font(.subheadline)
    }

    @ViewBuilder
    private func section<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(.primary)
            content()
        }
    }
}
