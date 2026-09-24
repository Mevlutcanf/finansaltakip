import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: DashboardViewModel?
    @State private var showAddTransaction = false
    @State private var showPrePurchaseCheck = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let viewModel {
                    summaryCards(viewModel: viewModel)
                    streakSection(viewModel: viewModel)
                    activeShieldSection(viewModel: viewModel)
                    recentTransactionsSection(viewModel: viewModel)
                    NavigationLink {
                        RoastView()
                    } label: {
                        Label("Roast My Wallet", systemImage: "flame")
                    }
                }
            }
            .padding()
        }
        .navigationTitle("AnPause")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button("Harcama Kaydet") { showAddTransaction = true }
                    Button("Alışveriş İsteği") { showPrePurchaseCheck = true }
                } label: {
                    Label("Yeni", systemImage: "plus.circle.fill")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    SettingsView()
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
        }
        .sheet(isPresented: $showPrePurchaseCheck) {
            PrePurchaseCheckView()
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DashboardViewModel(
                    transactionRepository: TransactionRepository(context: modelContext),
                    avoidedPurchaseRepository: AvoidedPurchaseRepository(context: modelContext),
                    shieldSessionRepository: ShieldSessionRepository(context: modelContext),
                    noSpendDayRepository: NoSpendDayRepository(context: modelContext)
                )
            }
            viewModel?.refresh()
        }
    }

    @ViewBuilder
    private func streakSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("\(viewModel.streak.noSpendDayStreak) günlük seri", systemImage: "flame.fill")
                    .font(.subheadline.weight(.medium))
                Spacer()
                if !viewModel.isTodayConfirmedNoSpend {
                    Button("Bugün harcama yapmadım") {
                        viewModel.confirmNoSpendToday()
                    }
                    .font(.caption.weight(.medium))
                    .buttonStyle(.bordered)
                }
            }
            Text("Bu hafta \(viewModel.streak.cooldownStreakThisWeek) kez dürtünü erteledin.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private func summaryCards(viewModel: DashboardViewModel) -> some View {
        VStack(spacing: 12) {
            SummaryCard(
                title: "Bu ay harcama",
                value: viewModel.monthlySpend.formatted,
                symbolName: "creditcard"
            )
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Kaçınılan alışveriş",
                    value: "\(viewModel.avoidedCount)",
                    symbolName: "hand.raised"
                )
                SummaryCard(
                    title: "Kaçınılan tutar",
                    value: viewModel.avoidedPotential.formatted,
                    symbolName: "banknote"
                )
            }
        }
    }

    @ViewBuilder
    private func activeShieldSection(viewModel: DashboardViewModel) -> some View {
        if !viewModel.activeShieldSessions.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Aktif Kalkan")
                    .font(.headline)
                ForEach(viewModel.activeShieldSessions) { session in
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundStyle(.orange)
                        Text("Bitiş: \(session.expiresAt.formatted(date: .omitted, time: .shortened))")
                        Spacer()
                    }
                    .padding()
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    @ViewBuilder
    private func recentTransactionsSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Son İşlemler")
                .font(.headline)

            if viewModel.recentTransactions.isEmpty {
                Text("Henüz kayıtlı işlem yok.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(viewModel.recentTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        }
    }
}

private struct SummaryCard: View {
    let title: String
    let value: String
    let symbolName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbolName)
                .foregroundStyle(.tint)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            Image(systemName: transaction.category.symbolName)
                .foregroundStyle(.tint)
            VStack(alignment: .leading) {
                Text(transaction.category.displayName)
                    .font(.subheadline.weight(.medium))
                Text(transaction.emotion.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.money.formatted)
                .font(.subheadline.weight(.semibold))
        }
        .padding(.vertical, 4)
    }
}
