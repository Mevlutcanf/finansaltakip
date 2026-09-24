import Foundation

/// V1 varsayılanı: gerçek AI zorunlu değil. Statik ve kurala dayalı metin
/// üretir; uydurma veri kullanmaz, yalnızca verilen aggregate özeti kullanır
/// (rehber madde 8).
final class LocalRoastService: RoastServiceProtocol {
    func generateRoast(summary: RoastInputSummary, tone: RoastTone) async -> String {
        var lines: [String] = []

        if let category = summary.topCategory {
            lines.append(categoryLine(category, tone: tone))
        }

        if let trigger = summary.topTrigger, summary.triggerOccurrenceCount > 0 {
            lines.append(triggerLine(trigger, count: summary.triggerOccurrenceCount, tone: tone))
        }

        if summary.avoidedCount > 0 {
            lines.append(avoidedLine(count: summary.avoidedCount, total: summary.avoidedTotal, tone: tone))
        }

        if lines.isEmpty {
            lines.append("Bu ay yeterli veri yok — birkaç harcama kaydettikçe burası dolacak.")
        }

        return lines.joined(separator: "\n\n")
    }

    private func categoryLine(_ category: SpendingCategory, tone: RoastTone) -> String {
        switch tone {
        case .mild:
            return "Bu ay en çok \(category.displayName.lowercased()) kategorisinde harcama yapmışsın."
        case .balanced:
            return "Bu ay en çok harcama yaptığın kategori \(category.displayName.lowercased()) olmuş."
        case .savage:
            return "\(category.displayName) kategorisi bu ay senin gözdenmiş, kartın da bunu hissetmiş."
        }
    }

    private func triggerLine(_ trigger: SpendingTrigger, count: Int, tone: RoastTone) -> String {
        switch tone {
        case .mild:
            return "\(count) kez '\(trigger.displayName.lowercased())' diyerek alışveriş yapmışsın."
        case .balanced:
            return "\(count) kez '\(trigger.displayName.lowercased())' tetikleyicisiyle harcama yapmışsın."
        case .savage:
            return "'\(trigger.displayName)' bahanesi bu ay \(count) kez işe yaramış — kartın buna alışmış olabilir."
        }
    }

    private func avoidedLine(count: Int, total: Money, tone: RoastTone) -> String {
        switch tone {
        case .mild:
            return "Cooldown sonrası \(count) alışverişten vazgeçmişsin. Toplam: \(total.formatted)."
        case .balanced:
            return "\(count) kez erteleyip vazgeçtin, toplamda \(total.formatted) kurtardın."
        case .savage:
            return "\(count) kez dürtünü yendin ve \(total.formatted) cebinde kaldı. Kartın bu ay yine maceracı davranmış ama sen daha güçlüydün."
        }
    }
}
