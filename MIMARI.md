# Mimari ve Teknik Detaylar

## Katmanlı Mimari
Uygulama aşağıdaki katmanlara ayrılmıştır:

- UI (Screens): `lib/screens/` — Flutter widget'ları, kullanıcı etkileşimleri ve navigasyon.
- Modeller: `lib/models/` — İş mantığı verilerini temsil eden sınıflar (`User`, `Exercise`, `TrainingProgram`, `LogEntry`).
- Servisler: `lib/services/` — Veri erişimi ve kalıcı depolama işlemleri. `StorageService` tüm CRUD operasyonlarını yönetir.
- Main: `lib/main.dart` — Uygulama başlatma, tema ve route mapping.

## Veri Saklama
- Local persistence için `shared_preferences` kullanılmıştır.
- Tüm karmaşık nesneler JSON'a serileştirilip `SharedPreferences` içerisine string olarak saklanır.

## Önemli Akışlar
- Kullanıcı kaydı: `StorageService.registerUser()` -> kullanıcı listesi güncellenir ve `current_user` ayarlanır.
- Giriş: `StorageService.loginUser()` -> kullanıcı doğrulanır ve `current_user` kaydedilir.
- Program kaydetme: `StorageService.saveTrainingProgram()` -> var olan programlar listesi güncellenir.
- Workout yükleme/kaydetme: `StorageService.loadWorkouts()` / `saveWorkouts()` -> günlük egzersiz listeleri yönetilir.

## Güvenlik Notları
- Şu an parola düz metin olarak saklanıyor; üretim için hashing (bcrypt vb.) ve güvenli saklama gereklidir.

## Geliştirme Notları
- Model migration için `fromJson` adaptasyonları ve defensive coding uygulanmıştır.
- `StorageService.initializeDefaultData()` ile uygulama ilk çalıştırıldığında test kullanıcıları oluşturulur.
