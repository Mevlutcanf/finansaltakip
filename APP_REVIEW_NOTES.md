# App Review Notes — AnPause (proje kod adı: MindSpend)

App Store Connect'te "App Review Information" bölümüne eklenecek taslak not
(rehber madde 38). Gönderim öncesi güncel App Review kurallarına göre
gözden geçirilmelidir.

> Not: Uygulamanın App Store'daki adı **AnPause**'dur ("MindSpend" adında
> App Store'da zaten iki uygulama olduğu için). Bundle ID
> (`com.anpause.app`) ve iç kod adı hâlâ MindSpend — bu doküman App
> Review'a gönderilecek metinde kullanıcıya görünen ismi (AnPause)
> kullanır.

---

AnPause, kullanıcıların dürtüsel alışveriş davranışlarını fark etmelerine
ve satın alma kararlarını ertelemelerine yardımcı olan bir davranışsal
finans uygulamasıdır.

**Family Controls / Screen Time kullanımı:** Uygulama, kullanıcının kendi
isteğiyle seçtiği alışveriş uygulamalarına ve web sitelerine geçici bir
"cooldown" (bekleme süresi) uygulamak için Family Controls çerçevesini
`individual` (bireysel) senaryoda kullanır. Bu bir ebeveyn denetimi
özelliği değildir — AnPause yalnızca kullanıcının kendi cihazında,
kendi seçtiği uygulamalara kendi isteğiyle geçici erişim kısıtlaması
uygular. Kullanıcı istediği zaman Ayarlar'dan bu kısıtlamayı kaldırabilir.

Uygulama, korunan uygulamaların içindeki hiçbir veriyi okumaz, hangi
uygulamaların kullanıldığını takip etmez ve bu bilgiyi hiçbir sunucuya
göndermez — seçimler yalnızca Apple'ın opak `ApplicationToken`/
`WebDomainToken` değerleri olarak cihazda saklanır.

**Veri toplama:** AnPause local-first çalışır. Harcama kayıtları, kaçınılan
alışverişler ve kalkan ayarları yalnızca kullanıcının cihazında SwiftData ile
saklanır. Hesap oluşturma zorunlu değildir, sunucu tarafı veri toplama
yoktur.

**Abonelik:** Premium abonelik RevenueCat üzerinden yönetilir; sınırsız
Kalkan Kuralı, gelişmiş içgörüler ve AI Roast gibi genişleyen değerler
sunar. Restore Purchases, Ayarlar > Ayarlar akışında değil Paywall
ekranında mevcuttur.

**Test hesabı:** Gerekmiyor — uygulama hesap oluşturmadan tamamen
kullanılabilir. Family Controls izni test sırasında "İzin Ver" ile
onaylanmalıdır.
