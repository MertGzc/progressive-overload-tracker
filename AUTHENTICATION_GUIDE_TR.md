# Antrenman Takip Uygulaması - Kullanıcı Kaydı ve Antrenör Sistemi Kurulum Rehberi

## ✅ Uygulamaya Eklenen Özellikler

### 1. **Kullanıcı Kaydı ve Kimlik Doğrulama Sistemi**
Uygulama artık kullanıcı kaydı ve giriş sistemi ile başlamaktadır.

#### Kaydolma Akışı:
- **Kullanıcı Adı**: Minimum 3 karakter
- **Parola**: Minimum 4 karakter, tekrar onayı gerekli
- **Rol Seçimi**: 
  - **Kullanıcı** (User): Antrenörlerin yazdığı programları takip edecek
  - **Antrenör** (Trainer): Diğer kullanıcılara program yazacak

#### Giriş:
- Kayıtlı kullanıcı adı ve parola ile giriş yapabilirsiniz

---

### 2. **Antrenör Paneli (Trainer Dashboard)**
Antrenör olarak giriş yapan kullanıcılar antrenör paneline yönlendirilir.

#### Antrenör Panelinde Yapılabilecekler:
1. **Tüm Kullanıcıları Görme**: Sistemdeki tüm kullanıcıların listesi
2. **Her Kullanıcıya Program Yazma**: 
   - Kullanıcıyı seçin
   - "Program Yaz" butonuna tıklayın
   - Haftanın her günü için egzersiz ekleyin
   - Program adı vererek kaydedin

#### Program Yazma Ekranında:
- Program adı belirleyin
- Gün seçin (Pazartesi - Pazar)
- Popüler egzersizler arasından seçin
- Birden fazla egzersiz ekleyebilirsiniz
- Program özeti gösterilir
- "Programı Kaydet" butonu ile tamamlayın

---

### 3. **Kullanıcı Ana Sayfası (Home Screen)**
Kullanıcı olarak giriş yapan kişiler ana sayfaya yönlendirilir.

#### Antrenör Programı Varsa:
- Antrenörün yazdığı program otomatik olarak gösterilir
- Sayfanın üstünde **"Antrenör Programı Görüntüleniyor"** uyarısı ve program adı gösterilir
- Programı gün gün takip edebilirsiniz
- Egzersiz detaylarına tıklayarak set/tekrar/ağırlık kaydedebilirsiniz

#### Antrenör Programı Yoksa:
- Kendi kişisel antrenman programınızı oluşturabilirsiniz
- Egzersiz ekleyebilir, silebilir, düzenleyebilirsiniz (eski sistem gibi)

---

## 📱 Uygulamayı Başlatma

### 1. Ilk Defa Çalıştırma:
```bash
cd c:\workout_tracker_mobile
flutter pub get
flutter run
```

### 2. İlk Ekran - Giriş/Kaydolma:
Uygulama açıldığında giriş/kaydolma ekranı görünecektir.

#### Test Amaçlı Kaydolma:
**Senaryo 1 - Kullanıcı Olarak:**
- Kullanıcı Adı: `kullanici1`
- Parola: `1234`
- Rol: **Kullanıcı**
- Kaydol → Otomatik giriş → Ana Sayfa

**Senaryo 2 - Antrenör Olarak:**
- Kullanıcı Adı: `antrenor1`
- Parola: `1234`
- Rol: **Antrenör**
- Kaydol → Otomatik giriş → Antrenör Paneli

---

## 🔄 Veri Akışı

### Antrenör → Kullanıcı İş Akışı:

```
1. Antrenör giriş yapar
   ↓
2. Antrenör panelinde kullanıcıları görür
   ↓
3. Bir kullanıcıya program yazar
   ↓
4. Program "Antrenman Programları" tablosunda kaydedilir
   ↓
5. Kullanıcı uygulamaya giriş yapar
   ↓
6. Sistem kendisine atanan antrenör programını bulur
   ↓
7. Ana sayfada antrenörün programı otomatik gösterilir
   ↓
8. Kullanıcı program üzerinden gün gün antrenman yapır
   ↓
9. Set/tekrar/ağırlık bilgilerini kaydeder
```

---

## 💾 Veri Depolama

Tüm veriler `SharedPreferences` kullanılarak cihazda depolanır:

- **`workout_tracker_users`**: Tüm kullanıcılar ve parolalar
- **`workout_tracker_current_user`**: Şu anda giriş yapan kullanıcı
- **`workout_tracker_training_programs`**: Antrenörler tarafından yazılan programlar
- **`workout_tracker_workouts`**: Kullanıcıların kendi antrenmanları
- **`workout_tracker_custom_exercises`**: Özel egzersizler

---

## 📝 Ekranlara Genel Bakış

### 1. **LoginRegisterScreen** (`login_register_screen.dart`)
- Giriş ve kaydolma seçenekleri
- Form doğrulaması
- Rol seçimi

### 2. **TrainerDashboardScreen** (`trainer_dashboard_screen.dart`)
- Tüm kullanıcıları listele
- Her kullanıcının yazılan programlarını göster
- Program yazma butonu

### 3. **TrainerWriteProgramScreen** (`trainer_write_program_screen.dart`)
- Antrenörün program yazması
- Gün seçimi
- Egzersiz seçimi
- Program adı belirtme

### 4. **HomeScreen** (güncellenmiş)
- Antrenör programı varsa onu göster
- Program yoksa kendi workouts'ları göster
- Kullanıcı adı göster
- Çıkış butonu

### 5. **MyApp** (main.dart - güncellenmiş)
- Giriş durumunu kontrol et
- Uygun ekrana yönlendir
- Named routes sistemi

---

## 🚀 Gelecek Özellikler (İsteğe Bağlı)

- [ ] Program düzenleme/silme
- [ ] Birden fazla program atama
- [ ] Antrenör notları
- [ ] İlerleme raporları
- [ ] Antrenör-Kullanıcı iletişim sistemi
- [ ] Program şablonları

---

## ⚙️ Teknik Notlar

- **Kimlik Doğrulama**: Basit username/password (üretim için güvenlik iyileştirilmeli)
- **Veritabanı**: SharedPreferences (lokal, cloud sync yok)
- **Rol Sistemi**: Binary (trainer/user) - genişletilebilir
- **Program Kaydı**: JSON formatında depolanır

---

## 🔐 Güvenlik Notları

⚠️ **ÜRETİM ÖNCESİ UYARISI:**
- Parolalar şu anda düz metin olarak depolanmaktadır
- Üretim için şifreli depolama yapılmalıdır
- Backend kimlik doğrulaması eklenmelidir
- HTTPS kullanılmalıdır

---

## 📞 Troubleshooting

### Eğer giriş yapamıyorsanız:
- Kullanıcı adı ve parolayı kontrol edin
- Kaydolma sırasında seçilen rolü kontrol edin
- Uygulamayı sıfırlamak için: `flutter clean` yapın

### Program görünmüyorsa:
- Antrenör doğru kullanıcıya program yazmış mı kontrol edin
- Kullanıcıyı çıkış yap (logout) → yeniden giriş yap
