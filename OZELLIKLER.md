# Uygulama Özellikleri (Detaylı)

## Kullanıcı Yönetimi
- Kayıt: `StorageService.registerUser()` ile lokal kullanıcı oluşturma
- Giriş/Çıkış: `StorageService.loginUser()` ve `logoutUser()`
- Roller: `trainer` ve `user` şeklinde ayrım

## Antrenman ve Program Yönetimi
- Günlere göre egzersiz listesi yönetimi
- Antrenörler için program oluşturma, kaydetme, güncelleme ve silme
- Programlar bir kullanıcıya atanabilir (`TrainingProgram.userId`)

## Egzersiz ve Loglama
- Egzersizler için hedef tekrar bilgisi
- Egzersiz bazlı log kayıtları (`LogEntry`) — tarih, kilo, setler
- `lastLog` ile son durum özetlenir

## Veri Yönetimi
- `SharedPreferences` üzerinden tüm uygulama verileri saklanır
- Varsayılan kullanıcılar ilk çalıştırmada oluşturulur (test amaçlı)

## UI
- Material 3 teması, koyu (dark) tema ön tanımlı
- Ekranlar: Giriş/Kayıt, Ana Ekran, Antrenör Paneli, Egzersiz Detayı vb.

## Eksik/İyileştirilecek Alanlar
- Parola güvenliği (hashing)
- Bulut senkronizasyonu
- Performans optimizasyonları (büyük veri için diğer DB çözümleri)

