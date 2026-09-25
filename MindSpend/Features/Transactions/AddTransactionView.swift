import SwiftUI
import SwiftData
import UIKit

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var amountText: String = ""
    @State private var category: SpendingCategory = .other
    @State private var emotion: Emotion = .neutral
    @State private var trigger: SpendingTrigger?
    @State private var note: String = ""
    @State private var didSave = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Tutar") {
                    TextField("0,00", text: $amountText)
                        .keyboardType(.decimalPad)
                }

                Section("Kategori") {
                    ChipGrid(items: SpendingCategory.allCases, selection: $category) { item in
                        Label(item.displayName, systemImage: item.symbolName)
                    }
                }

                Section("Şu an ne hissediyorsun?") {
                    ChipGrid(items: Emotion.allCases, selection: $emotion) { item in
                        Label(item.displayName, systemImage: item.symbolName)
                    }
                }

                Section("Bu isteği ne tetikledi? (opsiyonel)") {
                    ChipGrid(items: SpendingTrigger.allCases, selection: $trigger) { item in
                        Label(item.displayName, systemImage: item.symbolName)
                    }
                }

                Section("Not (opsiyonel)") {
                    TextField("Ekleyecek bir şey var mı?", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("Harcama Kaydet")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { save() }
                        .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        parsedAmountMinorUnits != nil
    }

    private var parsedAmountMinorUnits: Int64? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return Int64(truncating: (value * 100) as NSDecimalNumber)
    }

    private func save() {
        guard let minorUnits = parsedAmountMinorUnits else { return }
        let transaction = Transaction(
            amountMinorUnits: minorUnits,
            category: category,
            emotion: emotion,
            trigger: trigger,
            note: note.isEmpty ? nil : note
        )
        do {
            try TransactionRepository(context: modelContext).add(transaction)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            dismiss()
        } catch {
            // Kayıt başarısız oldu; kullanıcıya tekrar denemesi için form açık kalır.
        }
    }
}

/// Tek seçilebilir ya da opsiyonel seçime izin veren chip grid.
struct ChipGrid<Item: Identifiable & Hashable, Content: View>: View {
    let items: [Item]
    @Binding var selection: Item
    let content: (Item) -> Content

    init(items: [Item], selection: Binding<Item>, @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self._selection = selection
        self.content = content
    }

    var body: some View {
        FlowLayout(items: items) { item in
            content(item)
                .chipStyle(isSelected: item == selection)
                .onTapGesture {
                    SoundService.shared.play(.tick)
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        selection = item
                    }
                }
        }
    }
}

extension ChipGrid where Item: Hashable {
    init(items: [Item], selection: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self._selection = Binding(
            get: { selection.wrappedValue ?? items.first! },
            set: { newValue in
                selection.wrappedValue = (selection.wrappedValue == newValue) ? nil : newValue
            }
        )
        self.content = content
    }
}

private extension View {
    func chipStyle(isSelected: Bool) -> some View {
        self
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Theme.accent.opacity(0.18) : Color.secondary.opacity(0.08))
            .foregroundStyle(isSelected ? Theme.accent : Color.primary)
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(isSelected ? Theme.accent.opacity(0.5) : .clear, lineWidth: 1.5)
            )
            .scaleEffect(isSelected ? 1.04 : 1.0)
    }
}

struct FlowLayout<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], alignment: .leading, spacing: 8) {
            ForEach(items) { item in
                content(item)
            }
        }
    }
}
