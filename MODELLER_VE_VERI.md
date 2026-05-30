# Modeller ve Veri Yapıları

Bu doküman `lib/models/` içindeki sınıfların ve uygulamanın veri şekillerinin detaylarını içerir.

## `User`
- Alanlar:
  - `id` (String)
  - `username` (String)
  - `password` (String) — NOT: şu an düz metin
  - `role` (String) — `trainer` veya `user`
  - `createdAt` (DateTime)
- Kullanım: Auth akışında, antrenörlerin kullanıcı listelerini almak ve rol kontrolü için kullanılır.

## `Exercise`
- Alanlar:
  - `id` (String)
  - `name` (String)
  - `targetReps` (String) — hedef tekrar/kilo gibi metin bilgisi
  - `lastLog` (String?) — son kayıt özeti
  - `history` (List<LogEntry>?) — geçmiş log kayıtları
  - `assignedDays` (List<String>?) — hangi günlere atandığı
- Not: `assignedDays` alanı geriye dönük uyumluluk için kontrol edilip eklenmektedir.

## `LogEntry`
- Alanlar:
  - `id`, `date`, `weight`, `sets`, `day`
- Kullanım: Bir egzersiz için tarihsel kayıt tutma.

## `TrainingProgram`
- Alanlar:
  - `id`, `trainerId`, `userId`, `programName`, `exercises` (Map<String, List<Exercise>>), `createdAt`, `updatedAt`, `isActive`
- `exercises` yapısı: gün adı veya indeks -> egzersiz listesi

## Veri Saklama Formatı
- Tüm modeller `toJson()` ve `fromJson()` metotları ile JSON'a çevrilir.
- `SharedPreferences` içinde string olarak saklanır; anahtarlar `storage_service.dart` içinde tanımlıdır.

## Migration / Geriye Dönük Uyumluluk
- `StorageService` içinde yükleme metotları eski veri yapılarıyla uyumlu olacak şekilde korunmuştur (örn. `assignedDays` yoksa ekleme).

