# Testler ve Doğrulama

## Otomatik Testler
- Mevcut proje `test/widget_test.dart` içerir. Basit widget testi ve yapılandırma kontrolü sağlar.

Çalıştırma:
```bash
flutter test
```

## Manuel Test Senaryoları
1. Uygulamayı başlat, varsayılan kullanıcıların oluşturulduğunu doğrula.
2. Yeni kullanıcı kaydı oluştur (kullanıcı rolü `user`).
3. Kullanıcı ile giriş yap, `HomeScreen`'e ulaştığını doğrula.
4. Antrenör hesabı ile giriş yap (varsayılan: `antrenor1`), `TrainerDashboardScreen` erişimini kontrol et.
5. Program oluştur, kullanıcıya ata, atanan kullanıcı ile programı görüntüle.
6. Egzersiz ekle/güncelle/sil ve `StorageService` ile kalıcılığı kontrol et.

## Hata/Kaynak İzleme
- `print` ile loglama var; hataları console'dan takip edin.
- Daha kapsamlı hata takibi için Sentry veya benzeri bir hata izleme servisi eklenebilir.

## Öneriler
- Birim testleri ekle: `StorageService` CRUD işlemleri için.
- Widget testleri: login akışı, ana ekran render doğrulamaları.

