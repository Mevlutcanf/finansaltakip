# MindSpend — Davranışsal Finans ve Dürtü Kalkanı

> Dürtüsel alışveriş ile satın alma kararı arasına zaman ve farkındalık koyan
> kişisel finans uygulaması.

Ürün mantığı, teknik mimari ve faz planı için proje rehberine bakın
(kullanıcı tarafından `MindSpend_Claude_Code_Revize_Proje_Rehberi.md` olarak
sağlandı).

## Durum

Bu repo şu an **Xcode/Mac gerektirmeyen kaynak kod hazırlığı** aşamasında
geliştiriliyor (geliştirici ana bilgisayarında değil). Tamamlanan fazlar:

- **FAZ 0** — Proje klasör yapısı (bkz. rehber madde 45).
- **FAZ 1** — Domain enum'ları (`Emotion`, `SpendingTrigger`,
  `SpendingCategory`, `CooldownDuration`), SwiftData modelleri
  (`Transaction`, `AvoidedPurchase`, `ShieldRule`, `ShieldSession`),
  repository katmanı ve `ModelContainer` kurulumu.
- **FAZ 2** — Core UI: `DashboardView`, `AddTransactionView`,
  `PrePurchaseCheckView`, `HistoryView`, `AvoidedPurchasesView`,
  `InsightsView`, `ShieldSetupView` (Screen Time olmadan skeleton),
  `SettingsView`.

Henüz yapılmadı (bir sonraki adımlar):

- **Xcode projesi** (`.xcodeproj`) henüz oluşturulmadı — bkz.
  `MANUAL_APPLE_SETUP.md` madde 0. Bir Mac'e (veya CI'a) ihtiyaç var.
- **FAZ 3** — Family Controls / ManagedSettings / DeviceActivity
  entegrasyonu ve Shield extension'ları.
- **FAZ 4** — RevenueCat / Freemium.
- **FAZ 5** — Gamification + Roast My Wallet.
- **FAZ 6-7** — Privacy/Polish, TestFlight/App Store.

## Build hakkında önemli not

Bu geliştirme ortamında (Linux konteyner) Xcode/Swift toolchain
bulunmuyor, dolayısıyla bu commit'lerdeki Swift kodu **derlenerek
doğrulanamadı**. Kod dikkatle ve Apple'ın güncel SwiftUI/SwiftData API'lerine
göre yazıldı, ancak ana bilgisayara (veya GitHub Actions macOS runner'ına)
geçildiğinde ilk iş bir build almak olmalı.

Mac'iniz olmadığı biliniyor — bunun için `project.yml` (XcodeGen spec) ve
`.github/workflows/ios-build.yml` eklendi: her push'ta GitHub Actions'ın
macOS runner'ı XcodeGen ile `.xcodeproj`'u otomatik üretip simülatörde
build+test alıyor. Yani Mac sahibi olmadan da her commit'in derlenip
derlenmediğini görebilirsiniz (Actions sekmesinden). TestFlight dağıtımı
için `MANUAL_APPLE_SETUP.md` madde 5'teki secrets eklenmeli. iPhone'unuz
gerçek cihaz testleri (Screen Time dahil) ve TestFlight ile build'i indirip
denemek için yeterli.

## Klasör yapısı

Bkz. `MindSpend/` altındaki `App/ Core/ Domain/ Persistence/ Features/
Services/ ScreenTime/ Resources/ Tests/` klasörleri (rehber madde 45).
