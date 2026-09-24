import SwiftUI

struct PrivacyView: View {
    var body: some View {
        List {
            Section("Veri Saklama") {
                Text("AnPause local-first çalışır. Harcama kayıtların, kaçınılan alışverişlerin ve kalkan ayarların yalnızca bu cihazda, SwiftData ile saklanır. Hesap oluşturman gerekmez.")
                    .font(.subheadline)
            }

            Section("Screen Time") {
                Text("Seçtiğin uygulama ve web siteleri Apple'ın Family Controls çerçevesinde opak token olarak tutulur. AnPause hangi uygulamaları kullandığını okuyamaz veya bunları sunucuya göndermez.")
                    .font(.subheadline)
            }

            Section("Bulut") {
                Text("V1'de herhangi bir bulut senkronizasyonu yoktur. Verilerin yalnızca bu cihazda kalır.")
                    .font(.subheadline)
            }

            Section {
                NavigationLink("AI Veri Kullanımı") {
                    AIDataUsageView()
                }
            }
        }
        .navigationTitle("Gizlilik")
    }
}

struct AIDataUsageView: View {
    var body: some View {
        List {
            Section {
                Text("Roast My Wallet özelliği varsayılan olarak cihaz üzerinde, kurala dayalı bir servisle (LocalRoastService) çalışır — hiçbir veri dışarı gönderilmez.")
                    .font(.subheadline)
            }

            Section("Gelecekte AI Servisi Etkinleştirilirse") {
                Text("Yalnızca toplam harcama, kategori toplamları, duygu/tetikleyici dağılımı ve kaçınılan alışveriş özeti gibi aggregate veriler gönderilir. İşlem notların, ürün adların veya tam işlem listen varsayılan olarak gönderilmez.")
                    .font(.subheadline)
                Text("AI servisi başarısız olursa uygulama çalışmaya devam eder; roast özelliği sessizce yerel sürüme döner.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("AI Veri Kullanımı")
    }
}
