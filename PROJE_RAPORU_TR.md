# Antrenman Takip Uygulaması - Bitirme Projesi Raporu

## Özet
Bu proje, kullanıcıların antrenman programlarını oluşturup takip edebildiği, antrenörlerin kullanıcılara program atayabildiği ve antrenman geçmişinin saklandığı mobil bir Flutter uygulamasıdır. Uygulama offline çalışır ve veriler cihaz üzerinde `SharedPreferences` aracılığıyla saklanır.

## Proje Başlığı
Antrenman Takip Uygulaması

## Amaç ve Hedefler
- Kullanıcıların antrenmanlarını günlere göre planlayabilmesi.
- Antrenörlerin kullanıcılar için program oluşturup yönetebilmesi.
- Antrenman geçmişinin (set/tekrar/kilo) kaydedilmesi ve gösterilmesi.
- Basit, hafif ve platformlar arası bir mobil çözüm sunmak (Android/iOS).

## Kapsam
- Kullanıcı/Kayıt/Yetkilendirme (basit local auth)
- Antrenman listesi ve günlük atamalar
- Program oluşturma, kaydetme, silme ve atama
- Egzersiz geçmişi (log) ve son kayıt bilgisi
- Varsayılan veri ile hızlı başlatma

## Kullanılan Teknolojiler
- Flutter (Dart)
- SharedPreferences (Local persistence)
- Material 3 UI

## Mimarî Özeti
Uygulama katmanlara ayrılmıştır:
- UI / Screens: `lib/screens/` — kullanıcı arayüzü ve navigasyon
- Modeller: `lib/models/` — `User`, `Exercise`, `TrainingProgram`, `LogEntry`
- Servisler: `lib/services/` — veri yönetimi ve kalıcı depolama (`StorageService`)
- main: uygulama başlangıcı, tema ve route yönetimi (`lib/main.dart`)

## Önemli Dosyalar ve Sorumlulukları
- `lib/main.dart` — Uygulama başlatma, tema ve rota yönetimi
- `lib/models/*.dart` — Veri modelleri: `User`, `Exercise`, `TrainingProgram`, `LogEntry`
- `lib/services/storage_service.dart` — Tüm kalıcı veri işlemleri: kayıt/giriş, program yönetimi, workout kaydetme ve yükleme
- `lib/screens/` — Uygulama ekranları (login, home, trainer dashboard, exercise detail vb.)

## Veri Modelleri (Özet)
- `User`: `id`, `username`, `password`, `role`, `createdAt`
- `Exercise`: `id`, `name`, `targetReps`, `lastLog`, `history`, `assignedDays`
- `LogEntry`: `id`, `date`, `weight`, `sets`, `day`
- `TrainingProgram`: `id`, `trainerId`, `userId`, `programName`, `exercises` (gün->egzersiz listesi), `createdAt`, `updatedAt`, `isActive`

## Uygulama Akışı
1. Uygulama başlatılır. `StorageService.initializeDefaultData()` çalışır.
2. Mevcut kullanıcı kontrol edilir; yoksa login/register ekranı gösterilir.
3. Kullanıcı giriş yaptıktan sonra rolüne göre `HomeScreen` veya `TrainerDashboardScreen` gösterilir.
4. Kullanıcı antrenman ekleyebilir, log'layabilir; antrenör program oluşturup kullanıcılara atayabilir.

## Test ve Doğrulama
- Mevcut `test/widget_test.dart` temel widget testi içerir.
- Manuel test adımları: kayıt, giriş, program oluşturma, egzersiz ekleme, log kaydetme, veri kalıcılığı kontrolü.

## Karşılaşılan Zorluklar ve Çözümler
- Local persistence ve model migration: `StorageService` içinde verilerin geri uyumluluğu için kontroller ve atamalar eklendi (`assignedDays` alanı yoksa ekleme gibi).

## Geliştirilebilir Özellikler (Gelecek Çalışmalar)
- Sunucu tabanlı kullanıcı kimlik doğrulama ve yedekleme
- Senkronizasyon (bulut) ve çok cihaz desteği
- Zengin görselleştirme (grafikler) ve ilerleme raporları
- Medya (video/görsel) ile egzersiz açıklamaları

## Kaynaklar
- Flutter resmi dokümantasyonu: https://flutter.dev
- shared_preferences paketi: https://pub.dev/packages/shared_preferences

---
Raporun bu şablonunu istersen danışman adı, teslim tarihi, akademik format gibi bilgilerle genişletebilirim.