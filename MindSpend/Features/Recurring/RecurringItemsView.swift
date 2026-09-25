import SwiftUI
import SwiftData

/// Abonelikler ve diğer sürekli gider/gelirler için ayrı, opsiyonel bir
/// araç. Bilinçli olarak Dashboard'un davranışsal ana mesajına dahil
/// edilmez — yalnızca Ayarlar'dan erişilir.
struct RecurringItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: RecurringItemsViewModel?
    @State private var showAddItem = false

    var body: some View {
        List {
            if let viewModel {
                Section("Aylık Özet") {
                    LabeledContent("Sürekli giderler", value: viewModel.summary.monthlyExpenses.formatted)
                    LabeledContent("Sürekli gelirler", value: viewModel.summary.monthlyIncome.formatted)
                    LabeledContent("Net") {
                        Text(viewModel.summary.monthlyNet.formatted)
                            .foregroundStyle(viewModel.summary.monthlyNet.minorUnits >= 0 ? .green : .red)
                    }
                }

                if viewModel.items.isEmpty {
                    ContentUnavailableView(
                        "Henüz eklenmedi",
                        systemImage: "arrow.triangle.2.circlepath.circle",
                        description: Text("Abonelikler ve diğer sürekli gider/gelirlerini buraya ekleyebilirsin.")
                    )
                } else {
                    Section("Kayıtlar") {
                        ForEach(viewModel.items) { item in
                            RecurringItemRow(item: item, onToggle: { viewModel.toggleActive(item) })
                        }
                        .onDelete(perform: viewModel.delete)
                    }
                }
            }
        }
        .navigationTitle("Sürekli Gider/Gelir")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddItem = true
                } label: {
                    Label("Ekle", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddItem) {
            AddRecurringItemView { name, minorUnits, kind, cycle in
                viewModel?.addItem(name: name, amountMinorUnits: minorUnits, kind: kind, cycle: cycle)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = RecurringItemsViewModel(repository: RecurringItemRepository(context: modelContext))
            }
            viewModel?.refresh()
        }
    }
}

private struct RecurringItemRow: View {
    let item: RecurringItem
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: item.kind.symbolName)
                .foregroundStyle(item.kind == .income ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(!item.isActive)
                Text("\(item.cycle.displayName) · Aylık eşdeğer: \(item.monthlyEquivalent.formatted)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(item.money.formatted)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(item.isActive ? .primary : .secondary)
        }
        .contentShape(Rectangle())
        .swipeActions(edge: .leading) {
            Button(item.isActive ? "Duraklat" : "Etkinleştir", action: onToggle)
                .tint(item.isActive ? .orange : .green)
        }
    }
}

private struct AddRecurringItemView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var amountText: String = ""
    @State private var kind: RecurringItemKind = .expense
    @State private var cycle: BillingCycle = .monthly

    let onAdd: (String, Int64, RecurringItemKind, BillingCycle) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Tür") {
                    Picker("Tür", selection: $kind) {
                        ForEach(RecurringItemKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Ad") {
                    TextField("Örn. Netflix", text: $name)
                }
                Section("Tutar") {
                    TextField("0,00", text: $amountText)
                        .keyboardType(.decimalPad)
                }
                Section("Periyot") {
                    Picker("Periyot", selection: $cycle) {
                        ForEach(BillingCycle.allCases) { cycle in
                            Text(cycle.displayName).tag(cycle)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(kind == .expense ? "Yeni Gider" : "Yeni Gelir")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        if let minorUnits = parsedAmount {
                            onAdd(name, minorUnits, kind, cycle)
                            dismiss()
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && parsedAmount != nil
    }

    private var parsedAmount: Int64? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return Int64(truncating: (value * 100) as NSDecimalNumber)
    }
}
