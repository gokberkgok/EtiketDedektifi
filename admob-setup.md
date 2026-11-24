# AdMob Kurulumu (Kısa)

Uygulama şu an **Google test reklamlarıyla** çalışır. Yayına çıkmadan önce aşağıdakileri yap.

## 1. AdMob'da uygulama ve reklam birimleri
1. [admob.google.com](https://admob.google.com) → **Apps → Add app** → Android (ve istersen iOS).
2. Her platform için iki reklam birimi oluştur:
   - **Banner** (ürün raporunun altında)
   - **Rewarded interstitial** (karşılaştırma kilidi)
3. Not al: **App ID** (`ca-app-pub-…~…`) ve **Ad unit ID**'ler (`ca-app-pub-…/…`).

## 2. App ID'yi yerleştir
- Android: `android/app/src/main/AndroidManifest.xml` → `com.google.android.gms.ads.APPLICATION_ID` değerini kendi App ID'nle değiştir.
- iOS: `ios/Runner/Info.plist` → `GADApplicationIdentifier` değerini değiştir.

## 3. Reklam birimi kimliklerini build sırasında ver
Kod değiştirmeye gerek yok, `--dart-define` kullan:

```bash
flutter build appbundle --release --dart-define=ADMOB_ANDROID_BANNER=ca-app-pub-XXX/111 --dart-define=ADMOB_ANDROID_REWARDED_INTERSTITIAL=ca-app-pub-XXX/222
```

iOS için: `ADMOB_IOS_BANNER` ve `ADMOB_IOS_REWARDED_INTERSTITIAL`.
Verilmezse test kimlikleri kullanılır (`lib/services/ads/ad_config.dart`).

## 4. Onay (GDPR / UMP)
- AdMob → **Privacy & messaging** → **GDPR** mesajı oluştur ve yayınla.
- Uygulama açılışta onay formunu otomatik gösterir; gerekirse Ayarlar'da **Ad privacy options** görünür.

## 5. Play Store
- Play Console → **App content → Ads**: "Contains ads" işaretle.
- Gizlilik politikası URL'si ekle (AdMob ve Open Food Facts kullanımı belirtilmeli).
- `app-ads.txt` dosyasını geliştirici web sitende yayınla (AdMob → Apps → app-ads.txt).

## Önemli
- Kendi reklamlarına **asla tıklama**; test sırasında test kimliklerini kullan.
- Gerçek kimliklerle test edeceksen cihazını AdMob → **Settings → Test devices**'a ekle.
