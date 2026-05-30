# Kurulum ve Çalıştırma (Geliştirici Rehberi)

## Gereksinimler
- Flutter SDK (stable kanal önerilir)
- Android Studio (emülatör için) veya bir fiziksel cihaz
- (macOS için) Xcode iOS derlemeleri için

## Ortam Hazırlığı
1. Flutter kurulumunu tamamla: https://flutter.dev/docs/get-started/install
2. Ortam değişkenlerini ayarla ve `flutter doctor` çalıştırarak eksikleri gider.

## Proje İndirme ve Bağımlılıklar
```bash
git clone <repo-url>
cd workout_tracker_mobile
flutter pub get
```

## Uygulamayı Çalıştırma
- Debug modda bağlanmış cihaz veya emülatör ile:
```bash
flutter run
```

## Testler
- Birim/widget testleri çalıştır:
```bash
flutter test
```

## Yayın İçin Notlar
- SharedPreferences kullanımı nedeniyle kullanıcı verileri cihaz üzerinde saklanır; yayın öncesi parola güvenliği ve gizlilik politikası eklenmelidir.
- Android için `android/` içindeki imzalama yapılandırmaları ve iOS için `Runner` hedef ayarları kontrol edilmelidir.
