Flutter Ürün Etiketi Analiz Uygulaması – Geliştirme Promptu
Uygulama ismi : Etiket Dedektifi (EtiketDedektifi)
Build name : com.gokberk.etiketdedektifi
Proje dizini : Desktop/EtiketDedektifi
Tasarım kaynağı : Çark Döndürücü (Desktop/CarkDondurucu) tema sistemi ve bileşenleri
Arayüz dili : Türkçe (tarih ve sayı biçimi tr_TR)

1. Projenin Amacı
Flutter ve Dart ile, kullanıcının markette ya da gün içinde karşılaştığı bir ürünün barkodunu okutup birkaç saniye içinde etiketi anlayabildiği, kompakt ve minimal bir uygulama geliştir.
Uygulama bir takip/defter uygulaması değildir; anlık karar aracıdır: "Bu ürünü almalı mıyım?"
Temel gereksinimler:
Flutter ve Dart kullanılmalı.
Kendi backend'imiz ve veritabanımız olmamalı.
Ürün verisi ücretsiz ve açık API'lerden alınmalı.
Tarama geçmişi ve tercihler cihazda SharedPreferences ile saklanmalı.
Geçmişteki ürünler internet olmadan da yeniden açılabilmeli.
Uygulama AdMob reklamlarıyla gelir elde etmeli; reklamlar kullanıcı akışını engellememeli.
Kod yapısı modüler, sürdürülebilir ve geliştirilebilir olmalı.

2. Veri Kaynakları
Open Food Facts (gıda), Open Beauty Facts (kozmetik), Open Products Facts (diğer ürünler).
Ücretsiz, API anahtarı gerektirmez, ODbL lisanslıdır; kaynak her ürün raporunda belirtilmeli.
Sorgu sırası: Food → Beauty → Products. Ürün hiçbirinde yoksa "bulunamadı" durumu gösterilmeli.
Her istekte uygulamaya özgü bir User-Agent gönderilmeli, yalnızca gereken alanlar (fields) istenmeli.
Katkı maddeleri (E-kodları) Open Food Facts taksonomisinden üretilen gömülü bir asset ile çözülmeli (assets/data/additives.json); Türkçe adı olanlar Türkçe, işlev sınıfları Türkçe gösterilmeli.
Ürün adı ve içindekiler metninde varsa Türkçe alanlar (product_name_tr, ingredients_text_tr) önceliklendirilmeli; alerjenler Türkçe gösterilmeli.
Katkı riskleri yalnızca EFSA aşırı tüketim değerlendirmesine dayanmalı (yüksek / orta / düşük / işaretlenmemiş). Uydurma sağlık iddiası yapılmamalı.

3. Tasarım Dili
Çark Döndürücü'nün tasarım sistemi birebir kullanılmalı: renk token'ları, tipografi, radius ve boşluk sabitleri, kartlar, bottom sheet, chip, segment, boş durumlar, geri bildirimler.
Premium Dark ve Minimal Light temaları desteklenmeli; tercih kalıcı olmalı.
Vurgu rengi koyu temada lavanta, açık temada indigo. Yeşil / amber / mercan yalnızca karar renkleri (iyi / orta / sınırla) için kullanılmalı.
Ekranlarda sabit renk tanımlanmamalı; tüm renkler tema üzerinden gelmeli.
Arayüz kompakt olmalı: en önemli bilgi (karar ve puan) ilk ekranda görünmeli.
Logo: indigo–lavanta zemin üzerinde beyaz büyüteç; camın içinde karar renklerinden (yeşil, amber, mercan) oluşan barkod çizgileri. Kaynak dosyalar assets/branding/ altında.
Launcher ikonları flutter_launcher_icons, açılış ekranı flutter_native_splash ile üretilir (koyu zemin #10131C).

4. Navigasyon
Yüzen, minimal alt navigasyon: Home, History, ortada belirgin dairesel Scan butonu, Compare, Settings.
Scan butonu her ekrandan tek dokunuşla kamerayı açmalı.

5. Ekranlar
Home: selamlama, tema düğmesi, "Scan product" kartı, barkodu elle girme, son taramalar, etiket okuma rehberi (Nutri-Score, NOVA, E-kodları).
Scanner: tam ekran kamera, tarama penceresi, fener, "barkodu elle yaz" seçeneği, kamera izni yoksa anlaşılır durum.
Label report (ürün): karar kartı (0–100 Dedektif puanı + karar), puanın nedenleri, Nutri-Score ve NOVA rozetleri, besin seviyeleri (100 g başına), katkı maddeleri ve risk etiketleri, diyet ve alerjenler, içindekiler, veri kaynağı notu, altta banner reklam.
History: taranan ürünler, kaydırarak silme, tümünü temizleme, çevrimdışı yeniden açma.
Compare: geçmişten iki ürün seçme, ödüllü geçiş reklamıyla açılan karşılaştırma tablosu ve kazanan özeti.
Settings: tema seçimi, reklam gizlilik seçenekleri (UMP gerektiriyorsa), geçmişi temizleme, veri kaynakları ve lisans.

6. Dedektif Puanı
Tek merkezi mantık (ProductScorer) üzerinden hesaplanmalı.
Başlangıç 100. Nutri-Score: A 0, B −10, C −25, D −40, E −55. NOVA: 1 0, 2 −5, 3 −10, 4 −20.
Nutri-Score yoksa her "yüksek" besin seviyesi −6.
EFSA yüksek riskli katkı −15, orta riskli −7; katkı cezası en fazla −40.
Sonuç 0–100 arasına sabitlenir: 70+ Great choice, 40–69 Okay in moderation, 40 altı Better to limit.
Besin verisi yoksa puan uydurulmamalı; "Not enough data" gösterilmeli.

7. Reklam (AdMob)
google_mobile_ads ile banner (ürün raporunun altında) ve ödüllü geçiş reklamı (karşılaştırmanın kilidi).
Ödüllü geçiş reklamından önce kullanıcıya atlama seçeneği sunan bir tanıtım ekranı gösterilmeli.
Reklam yüklenemezse ya da gösterilemezse kullanıcı engellenmemeli; yalnızca reklamı erken kapatırsa kilit açılmamalı.
Reklamlar UMP onayı alındıktan sonra başlatılmalı.
Reklam birimi kimlikleri koda gömülmemeli; --dart-define ile verilmeli, varsayılan olarak Google test kimlikleri kullanılmalı.
Ayrıntılar: admob-setup.md

8. Teknik Mimari
lib/
 ├── main.dart
 ├── app.dart
 ├── core/ (constants, theme, utils, widgets)
 ├── models/ (product.dart, additive.dart)
 ├── services/ (product_api_service, additive_catalog, product_score, local_storage_service, ads/)
 ├── state/ (app_scope, history_store, settings_controller)
 ├── features/ (home, scanner, product, history, compare, settings)
 └── navigation/ (bottom_navigation.dart)
Durum yönetimi: ChangeNotifier + InheritedWidget (AppScope), harici state paketi yok.
Ağ hataları (zaman aşımı, bağlantı yok, sunucu hatası) kullanıcıya anlaşılır mesajla gösterilmeli ve tekrar denenebilmeli.

9. Geliştirme Kuralları
Clean code; kod içinde yorum satırı yok.
Anlaşılır isimler; tekrarlanan kod ortak widget veya yardımcıya taşınmalı.
UI ile veri/iş mantığı ayrı tutulmalı.
Kullanılmayan import, değişken ve paket bırakılmamalı; gereksiz bağımlılıktan kaçınılmalı.
flutter analyze temiz olmalı, ayrıştırma ve puan mantığı testlerle korunmalı.
Farklı ekran boyutlarında taşma olmamalı.
Uygulama çalışır durumda olmalı; yalnızca görsel prototip yapılmamalı.
