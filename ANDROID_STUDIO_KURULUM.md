# Android Studio'da Flutter Uygulamasını Çalıştırma

## 1. Android Studio'yu Açın

Android Studio'yu açın.

## 2. Flutter Projesini Açın

1. **File > Open** menüsüne tıklayın
2. `workout_tracker_mobile` klasörünü seçin
3. **OK** butonuna tıklayın

Veya:
- Android Studio açıkken **File > Open**
- `C:\Users\mrt_g\Desktop\workout_tracker_mobile` yolunu seçin

## 3. Flutter Plugin Kontrolü

İlk kez açıyorsanız:
1. Android Studio Flutter plugin'i yüklü mü kontrol edin
2. **File > Settings** (Windows) veya **Android Studio > Preferences** (Mac)
3. **Plugins** sekmesine gidin
4. "Flutter" arayın ve yüklü olduğundan emin olun
5. Yüklü değilse **Install** butonuna tıklayın

## 4. Emulator Oluşturma (İlk Kez)

Eğer henüz emulator oluşturmadıysanız:

1. Android Studio'da üst menüden **Tools > Device Manager** (veya sağ üstteki cihaz ikonuna tıklayın)
2. **Create Device** butonuna tıklayın
3. Bir cihaz seçin (örn: **Pixel 5** veya **Pixel 6**)
4. **Next** butonuna tıklayın
5. Sistem görüntüsü seçin (API 33 veya 34 önerilir)
6. **Download** butonuna tıklayarak indirin (gerekirse)
7. **Next** ve **Finish** butonlarına tıklayın

## 5. Emulator'ü Başlatın

1. **Device Manager**'da oluşturduğunuz emulator'ün yanındaki **Play (▶)** butonuna tıklayın
2. Emulator açılmasını bekleyin (birkaç dakika sürebilir)

## 6. Uygulamayı Çalıştırın

### Yöntem 1: Run Butonu
1. Android Studio'da üst menüden **Run > Run 'main.dart'** (veya yeşil **▶** butonuna tıklayın)
2. Açılan listeden emulator'ünüzü seçin
3. Uygulama emulator'de açılacaktır

### Yöntem 2: Terminal
1. Android Studio'nun alt kısmındaki **Terminal** sekmesine tıklayın
2. Şu komutu yazın:
```bash
flutter run
```

## 7. Hot Reload (Hızlı Yenileme)

Kod değişikliklerini görmek için:
- **r** tuşuna basın (hot reload)
- **R** tuşuna basın (hot restart - tam yeniden başlatma)

## 8. Debugging

Hata ayıklama için:
1. Kod satırlarının soluna tıklayarak **breakpoint** ekleyin
2. **Run > Debug 'main.dart'** ile debug modunda çalıştırın
3. **Debug** sekmesinde değişkenleri inceleyebilirsiniz

## Sorun Giderme

### Emulator açılmıyor:
- **Tools > SDK Manager** > **SDK Tools** sekmesinde **Android Emulator** işaretli olduğundan emin olun
- Bilgisayarınızda **Virtualization** (VT-x/AMD-V) açık olmalı (BIOS'tan kontrol edin)

### Flutter komutları çalışmıyor:
- Terminal'de `flutter doctor` komutunu çalıştırın
- Eksik olan şeyleri yükleyin

### Gradle hatası:
- **File > Invalidate Caches / Restart** yapın
- **Build > Clean Project** yapın
- **Build > Rebuild Project** yapın

## Hızlı Başlangıç Komutları

Terminal'de (Android Studio'nun alt kısmında):

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run

# APK oluştur
flutter build apk

# Emulator listesini gör
flutter emulators

# Emulator başlat
flutter emulators --launch <emulator_id>
```

## Önemli Notlar

- İlk çalıştırmada Gradle indirmeleri yapılabilir (internet gerekli)
- Emulator ilk açılışta biraz yavaş olabilir
- Uygulama verileri emulator'de kalıcı olarak saklanır
- Emulator'ü kapatıp açtığınızda veriler kaybolmaz
