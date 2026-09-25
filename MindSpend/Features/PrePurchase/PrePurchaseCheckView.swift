import SwiftUI
import SwiftData

private enum PrePurchaseStep {
    case intro
    case amount
    case emotion
    case trigger
    case decision
}

struct PrePurchaseCheckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var step: PrePurchaseStep = .intro
    @State private var itemName: String = ""
    @State private var amountText: String = ""
    @State private var emotion: Emotion = .neutral
    @State private var trigger: SpendingTrigger?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                switch step {
                case .intro:
                    introStep
                case .amount:
                    amountStep
                case .emotion:
                    emotionStep
                case .trigger:
                    triggerStep
                case .decision:
                    decisionStep
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Alışveriş İsteği")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
        }
    }

    private var introStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bunu şimdi gerçekten almak istiyor musun?")
                .font(.title2.bold())
            Text("Birkaç kısa soru, kararını netleştirmene yardımcı olacak.")
                .foregroundStyle(.secondary)
            Button("Devam Et") { step = .amount }
                .buttonStyle(.borderedProminent)
        }
    }

    private var amountStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ne almak istiyorsun?")
                .font(.title3.bold())
            TextField("Ürün adı (opsiyonel)", text: $itemName)
                .textFieldStyle(.roundedBorder)
            TextField("Tutar", text: $amountText)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
            Button("Devam Et") { step = .emotion }
                .buttonStyle(.borderedProminent)
                .disabled(parsedAmountMinorUnits == nil)
        }
    }

    private var emotionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Şu an ne hissediyorsun?")
                .font(.title3.bold())
            ChipGrid(items: Emotion.allCases, selection: $emotion) { item in
                Label(item.displayName, systemImage: item.symbolName)
            }
            Button("Devam Et") { step = .trigger }
                .buttonStyle(.borderedProminent)
        }
    }

    private var triggerStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Bu alışveriş neden cazip geliyor?")
                .font(.title3.bold())
            ChipGrid(items: SpendingTrigger.allCases, selection: $trigger) { item in
                Label(item.displayName, systemImage: item.symbolName)
            }
            Button("Devam Et") { step = .decision }
                .buttonStyle(.borderedProminent)
        }
    }

    private var decisionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ne yapmak istersin?")
                .font(.title3.bold())

            Button("Şimdi Al") { savePurchased() }
                .buttonStyle(.bordered)

            Divider()

            Text("Ya da erteleyip biraz zaman kazan:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(CooldownDuration.allCases) { duration in
                Button(duration.displayName) { saveAvoided(duration: duration) }
                    .buttonStyle(.borderedProminent)
            }
        }
    }

    private var parsedAmountMinorUnits: Int64? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else { return nil }
        return Int64(truncating: (value * 100) as NSDecimalNumber)
    }

    private func savePurchased() {
        guard let minorUnits = parsedAmountMinorUnits else { return }
        let transaction = Transaction(
            amountMinorUnits: minorUnits,
            category: .other,
            emotion: emotion,
            trigger: trigger,
            note: itemName.isEmpty ? nil : itemName
        )
        try? TransactionRepository(context: modelContext).add(transaction)
        dismiss()
    }

    private func saveAvoided(duration: CooldownDuration) {
        guard let minorUnits = parsedAmountMinorUnits else { return }
        let now = Date.now
        let pending = AvoidedPurchase(
            itemName: itemName.isEmpty ? "Belirtilmedi" : itemName,
            amountMinorUnits: minorUnits,
            cooldownStartedAt: now,
            cooldownExpiresAt: duration.expirationDate(from: now),
            emotion: emotion,
            trigger: trigger,
            status: .pending
        )
        try? AvoidedPurchaseRepository(context: modelContext).add(pending)
        NotificationService.shared.scheduleCooldownExpiringSoon(for: pending)
        NotificationService.shared.scheduleCooldownExpired(for: pending)
        dismiss()
    }
}
