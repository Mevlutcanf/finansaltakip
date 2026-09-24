# MindSpend — Davranışsal Finans ve Dürtü Kalkanı

> Dürtüsel alışveriş ile satın alma kararı arasına zaman ve farkındalık koyan
> kişisel finans uygulaması.

Ürün mantığı, teknik mimari ve faz planı için proje rehberine bakın
(kullanıcı tarafından `MindSpend_Claude_Code_Revize_Proje_Rehberi.md` olarak
sağlandı).

## Durum

Bu repo **Xcode/Mac gerektirmeyen kaynak kod hazırlığı** aşamasında
geliştirildi (geliştirici ana bilgisayarında değilken). FAZ 0-6 tamamlandı:

- **FAZ 0** — Proje klasör yapısı (bkz. rehber madde 45).
- **FAZ 1** — Domain enum'ları (`Emotion`, `SpendingTrigger`,
  `SpendingCategory`, `CooldownDuration`), SwiftData modelleri
  (`Transaction`, `AvoidedPurchase`, `ShieldRule`, `ShieldSession`,
  `NoSpendDay`), repository katmanı ve `ModelContainer` kurulumu.
- **FAZ 2** — Core UI: `DashboardView`, `AddTransactionView`,
  `PrePurchaseCheckView`, `HistoryView`, `AvoidedPurchasesView`,
  `InsightsView`, `SettingsView`.
- **FAZ 3** — Family Controls authorization, `FamilyActivityPicker`,
  `ManagedSettingsStore` shield, `ShieldConfiguration`/`ShieldAction`/
  `DeviceActivityMonitor` extension'ları, App Group tabanlı paylaşımlı
  durum.
- **FAZ 4** — `IAPServiceProtocol` soyutlaması, `LocalIAPService`
  (varsayılan) / `RevenueCatIAPService`, `SubscriptionManager`,
  `PaywallView`, free tier limiti (1 Shield Rule).
- **FAZ 5** — `NoSpendDay` streak'i, `RoastServiceProtocol` /
  `LocalRoastService`, `RoastView` (paylaşılabilir kart).
- **FAZ 6** — `OnboardingView`, `PrivacyView` / `AIDataUsageView`,
  `ExportService` (CSV/JSON), haftalık reflection bildirimi.

Henüz yapılmadı (manuel / Apple tarafı — bkz. `MANUAL_APPLE_SETUP.md` ve
`APP_REVIEW_NOTES.md`):

- **Xcode projesi** (`.xcodeproj`) henüz elle oluşturulmadı; CI (`project.yml`
  + XcodeGen) bunu her push'ta otomatik üretip build/test alıyor ama gerçek
  cihazda/TestFlight'ta ilk çalıştırma için Apple Developer + App Store
  Connect kurulumu (madde 1-4) gerekiyor.
- **FAZ 7** — TestFlight dağıtımı, App Store submission — tamamen manuel
  adımlar, `MANUAL_APPLE_SETUP.md`'de checklist halinde.

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
