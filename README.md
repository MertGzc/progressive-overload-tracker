# Antrenman Takip Uygulaması

Bu depo, Flutter ile geliştirilmiş "Antrenman Takip Uygulaması"nın kaynak kodunu içerir. Uygulama, kullanıcıların antrenman programlarını oluşturmasına, egzersizlerini loglamasına ve antrenörlerin programları yönetmesine olanak sağlar.

## Özellikler
- Yerel kullanıcı kayıt ve giriş (local auth)
- Rol bazlı ara yüz: `user` ve `trainer`
- Antrenman programı oluşturma, düzenleme, silme
- Egzersiz günlerine atama ve tekrar/weight loglama
- Varsayılan test kullanıcıları ile hızlı başlangıç
- Tüm veriler cihaz üzerinde `SharedPreferences` ile saklanır

## Teknik Yığın
- Flutter + Dart
- shared_preferences
- Material 3

## Hızlı Başlangıç (Geliştirici)
Ön koşullar:
- Flutter SDK (sürüm uyumluluğunu `pubspec.yaml` ile kontrol edin)
- Android Studio / Xcode (mobil emülatörler için)

Çalıştırma:
```bash
flutter pub get
flutter run
```

Testler:
```bash
flutter test
```

## Proje Yapısı (Öne Çıkanlar)
- `lib/main.dart` — Uygulama başlangıcı, theme ve route yönetimi
- `lib/screens/` — Ekranlar
- `lib/models/` — Veri modelleri
- `lib/services/storage_service.dart` — Kalıcı veri ve iş mantığı

## Notlar
- Uygulama offline-first tasarımı benimser; daha ileri özellikler için backend entegrasyonu önerilir.
- Kullanıcı parolaları şu an düz metin olarak saklanıyor; gerçek uygulamalar için şifreleme/hashed storage gereklidir.

