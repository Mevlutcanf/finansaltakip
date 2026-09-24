# MindSpend — Manuel Apple Kurulum Checklist'i

Bu dosya, Claude Code'un yapamadığı (Apple Developer portal, App Store Connect,
RevenueCat dashboard, imzalama) işlemleri listeler. Mac'iniz olmadığı için bu
adımların bir kısmını **iPhone üzerinden Apple Developer app / App Store
Connect app** ile, bir kısmını da (Xcode gerektiren adımlar) GitHub Actions
macOS runner + `fastlane` üzerinden otomatikleştireceğiz. Xcode projesinin
kendisi bir Mac'te (veya CI'da) bir kez oluşturulmalı — bkz. aşağıdaki not.

## 0. Xcode Projesi Oluşturma (bir kereliğine gerekli)

Bu repodaki `MindSpend/` klasörü kaynak dosyaları içerir ama henüz bir
`.xcodeproj`/`.xcworkspace` yok — bunu elle (Xcode olmadan) güvenilir şekilde
üretmek riskli. İki seçenek:

- **Seçenek A (önerilen):** Bir arkadaşınızın Mac'inde veya App Store'daki
  "Swift Playgrounds" / geçici bir bulut Mac hizmetinde (örn. MacinCloud,
  GitHub Codespaces + macOS gibi) Xcode açıp: File → New → Project → App,
  Bundle ID: `com.mindspend.app` (örnek), Interface: SwiftUI, Storage:
  SwiftData seçin. Sonra `MindSpend/` klasöründeki dosyaları projeye sürükleyin
  ve gruplara (App, Domain, Persistence, Features, Services, ScreenTime)
  ayırın.
- **Seçenek B (uygulandı):** `project.yml` (XcodeGen spec) ve
  `.github/workflows/ios-build.yml` repoya eklendi. Her push'ta CI, XcodeGen
  ile `.xcodeproj`'u otomatik üretip simülatörde build+test alıyor. Kendi
  Mac'inizde de çalıştırmak isterseniz: `brew install xcodegen && xcodegen
  generate` yeterli, sonrasında `MindSpend.xcodeproj` Xcode'da açılabilir.

## 1. Apple Developer Hesabı

- [ ] Apple Developer Program üyeliği (yıllık $99) — İphone'dan da
      developer.apple.com üzerinden kayıt olunabilir.
- [ ] Bundle ID oluşturma: `com.mindspend.app` (Identifiers → App IDs).
- [ ] **Family Controls** capability'sini Bundle ID'ye ekleme.
- [ ] Family Controls **distribution entitlement** başvurusu (Apple'a ayrı
      onay başvurusu gerekir — "Request additional capabilities" formu).
      Bu onay süre alabilir, mümkün olduğunca erken başvurun.
- [ ] Extension'lar için ayrı Bundle ID'ler:
      - `com.mindspend.app.ShieldConfiguration`
      - `com.mindspend.app.ShieldAction`
      - `com.mindspend.app.DeviceActivityMonitor`
- [ ] App Group oluşturma: `group.com.mindspend.app` (ana app + extension'lar
      arasında paylaşılan hafif storage için).

## 2. Certificates & Provisioning

- [ ] Development ve Distribution certificate'ları (Xcode "Automatically
      manage signing" ile CI'da da halledilebilir, fastlane `match` önerilir).
- [ ] Provisioning profile'lar (ana app + 3 extension) Family Controls
      entitlement'ını içerecek şekilde.

## 3. App Store Connect

- [ ] Yeni app kaydı (Bundle ID, isim, SKU).
- [ ] Subscription group + premium ürün tanımı (fiyat, süre — aylık/yıllık).
- [x] App Review Notes taslağı: `APP_REVIEW_NOTES.md` — App Store Connect'e
      kopyalanmadan önce güncel App Review kurallarına göre gözden geçirin.
- [ ] Privacy Nutrition Labels (toplanan veri: yok/aggregate, local-first).
- [ ] TestFlight iç test grubu.

## 4. RevenueCat

- [ ] RevenueCat hesabı, proje oluşturma.
- [ ] App Store Connect API key bağlama.
- [ ] Ürün/offering tanımlama (App Store Connect'teki subscription ile eşleşen).
- [ ] Public SDK key'i alıp `MindSpendApp.swift` içinde
      `RevenueCatIAPService.configure(apiKey:)` çağırma ve
      `SubscriptionManager(service: RevenueCatIAPService())` ile
      `LocalIAPService` yerine geçme (şu an varsayılan `LocalIAPService` —
      kullanıcı her zaman free kalıyor, RevenueCat yapılandırılana kadar
      uygulama sorunsuz çalışır).

## 5. CI/CD (Mac'iniz olmadığı için)

- [x] `.github/workflows/ios-build.yml` eklendi — her push'ta macOS
      runner'da XcodeGen ile proje üretip build/test alır.
- [ ] TestFlight'a otomatik yükleme için `fastlane` + App Store Connect API
      key GitHub Secrets'a eklenmeli: `ASC_KEY_ID`, `ASC_ISSUER_ID`,
      `ASC_KEY_CONTENT`, imzalama için `MATCH_PASSWORD` vb.
- [ ] Bu secrets eklendiğinde CI workflow'u genişletip otomatik TestFlight
      dağıtımı kurabiliriz.

## 6. Fiziksel Cihaz Testi (iPhone'unuzla yapılabilir)

Rehberin 35. bölümündeki Screen Time test listesi gerçek cihaz gerektirir:
authorization, app/web domain seçimi, shield aktivasyonu, cooldown bitişi,
app yeniden başlatma, cihaz yeniden başlatma, authorization iptali. Bunlar
TestFlight üzerinden iPhone'unuza gelen build ile test edilebilir — Mac
gerekmez.
