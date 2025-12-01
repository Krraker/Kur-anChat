# Flutter Mobil Uygulama Kurulum Rehberi

Bu rehber, Ayet Rehberi Flutter mobil uygulamasının kurulumunu adım adım açıklar.

## 📋 Gereksinimler

- Flutter 3.0 veya üzeri
- Dart 3.0 veya üzeri
- iOS geliştirme için: macOS + Xcode 14+
- Android geliştirme için: Android Studio + JDK

## 🚀 Hızlı Başlangıç

### 1. Flutter Kurulumu

Flutter henüz kurulu değilse:

#### macOS
```bash
brew install --cask flutter
```

#### Linux
```bash
# Flutter'ı indirin
git clone https://github.com/flutter/flutter.git -b stable
# PATH'e ekleyin
export PATH="$PATH:`pwd`/flutter/bin"
```

#### Windows
1. https://docs.flutter.dev/get-started/install/windows adresinden indirin
2. ZIP dosyasını çıkarın
3. PATH'e ekleyin

### 2. Flutter Doktor Kontrolü

```bash
flutter doctor
```

Eksik olan gereksinimleri yükleyin (Android Studio, Xcode, vb.)

### 3. Projeyi Hazırlayın

```bash
cd mobile
flutter pub get
```

### 4. Backend URL'ini Ayarlayın

`mobile/lib/services/api_service.dart` dosyasını açın ve `baseUrl` değişkenini düzenleyin:

```dart
// iOS Simulator için
static const String baseUrl = 'http://localhost:3001/api';

// Android Emulator için
static const String baseUrl = 'http://10.0.2.2:3001/api';

// Fiziksel cihaz için (bilgisayarınızın local IP'si)
static const String baseUrl = 'http://192.168.1.100:3001/api';
```

**Not:** Bilgisayarınızın IP adresini öğrenmek için:
- macOS/Linux: `ifconfig | grep inet`
- Windows: `ipconfig`

### 5. Backend'i Başlatın

Yeni bir terminal açın:

```bash
cd backend
npm run start:dev
```

Backend `http://localhost:3001` adresinde çalışmalı.

### 6. Mobil Uygulamayı Çalıştırın

#### iOS Simulator (macOS)

```bash
# Simulator'ı başlat
open -a Simulator

# Uygulamayı çalıştır
cd mobile
flutter run
```

#### Android Emulator

```bash
# Android Studio'dan emulator başlatın veya:
flutter emulators --launch <emulator-id>

# Uygulamayı çalıştır
cd mobile
flutter run
```

#### Fiziksel Cihaz

**iOS:**
1. iPhone'u Mac'e USB ile bağlayın
2. iPhone'da "Trust This Computer" seçin
3. Xcode'da geliştirici hesabınızı ekleyin
4. `flutter run` komutuyla çalıştırın

**Android:**
1. Telefonda Ayarlar → Geliştirici Seçenekleri → USB Debugging'i açın
2. Telefonu USB ile bağlayın
3. "Allow USB Debugging" onaylayın
4. `flutter run` komutuyla çalıştırın

## 🔧 Detaylı Yapılandırma

### iOS Yapılandırması

1. Xcode projesini açın:
```bash
open ios/Runner.xcworkspace
```

2. Bundle Identifier'ı değiştirin (isteğe bağlı):
   - Runner → Signing & Capabilities
   - Bundle Identifier: `com.yourcompany.ayetrehberi`

3. Geliştirici hesabınızı ekleyin:
   - Xcode → Preferences → Accounts
   - Apple ID ekleyin

### Android Yapılandırması

1. `android/app/build.gradle` dosyasında app ID'yi değiştirin (isteğe bağlı):

```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.ayetrehberi"
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

2. App adını değiştirin:

`android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Ayet Rehberi"
    ...>
```

## 📱 Platform-Specific Notlar

### iOS

**Minimum iOS Version:** 12.0

**Info.plist Ayarları:**

Backend'e HTTP istekleri için (development):
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Production için HTTPS kullanın!**

### Android

**Minimum SDK:** 21 (Android 5.0)
**Target SDK:** 33 (Android 13)

**Internet İzni:**

`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

**HTTP İzni (development için):**

`android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

## 🎨 Uygulama İçeriği

### Ekranlar
- **ChatScreen**: Ana sohbet ekranı
  - Mesaj listesi
  - Otomatik scroll
  - Loading göstergesi

### Widgetlar
- **MessageBubble**: Kullanıcı ve asistan mesajları
- **VerseCard**: Kuran ayetlerini gösteren kart
- **ChatInput**: Mesaj giriş alanı
- **EmptyState**: Boş durum ekranı (örnek sorularla)

### State Management
- **Provider** kullanılıyor
- **ChatProvider**: Mesaj ve API yönetimi

### API İletişimi
- **ApiService**: REST API çağrıları
- **http** paketi ile backend iletişimi

## 🐛 Sık Karşılaşılan Sorunlar

### 1. Backend'e bağlanamıyorum

**Semptom:** "Failed to connect" hatası

**Çözüm:**
- Backend'in çalıştığından emin olun (`npm run start:dev`)
- Doğru URL kullanın:
  - iOS: `localhost` veya bilgisayar IP'si
  - Android: `10.0.2.2` (emulator) veya bilgisayar IP'si (fiziksel cihaz)
- Firewall ayarlarını kontrol edin
- iOS için Info.plist'te HTTP izni olduğundan emin olun

### 2. CocoaPods hatası (iOS)

**Hata:** "CocoaPods not installed"

**Çözüm:**
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

### 3. Gradle hatası (Android)

**Hata:** "Gradle build failed"

**Çözüm:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 4. Hot Reload çalışmıyor

**Çözüm:**
```bash
# Terminalde R tuşuna basın (Hot Restart)
# veya
flutter clean
flutter run
```

### 5. Paket yüklenemiyor

**Hata:** "pub get failed"

**Çözüm:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

## 🚀 Production Build

### Android APK

```bash
cd mobile
flutter build apk --release
```

APK dosyası: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

App bundle: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Ardından Xcode ile:
1. Product → Archive
2. Distribute App
3. App Store Connect'e yükle

## 📊 Build Boyutları

Optimize edilmiş release buildlar:
- Android APK: ~15-20 MB
- iOS IPA: ~20-25 MB

## 🔐 Güvenlik

Production için:
1. HTTPS kullanın
2. API key'leri environment variables'da saklayın
3. Certificate pinning ekleyin
4. Code obfuscation kullanın:
   ```bash
   flutter build apk --obfuscate --split-debug-info=build/debug-info
   ```

## 📈 Performance İpuçları

1. **Build Mode:** Release build kullanın
   ```bash
   flutter run --release
   ```

2. **Image Optimization:** Büyük görselleri compress edin

3. **Lazy Loading:** Uzun listeler için `ListView.builder` kullanın

4. **Profiling:**
   ```bash
   flutter run --profile
   # DevTools açın
   flutter pub global activate devtools
   flutter pub global run devtools
   ```

## 🧪 Testing

### Widget Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

## 📱 Store Yayınlama

### Google Play Store

1. App Bundle oluştur
2. Google Play Console'da uygulama oluştur
3. Store listing bilgilerini doldur
4. Screenshots ekle
5. Test kullanıcıları ekle (Internal Testing)
6. Production'a yayınla

### Apple App Store

1. App Store Connect'te uygulama oluştur
2. TestFlight için build yükle
3. Test kullanıcıları davet et
4. App Review için gönder
5. Onaylandıktan sonra yayınla

## 🔄 Güncelleme

Backend API değişirse:
1. `lib/models/` içindeki modelleri güncelleyin
2. `lib/services/api_service.dart` güncelleyin
3. UI componentlerini güncelleyin

## 📚 Kaynaklar

- [Flutter Dokümantasyonu](https://docs.flutter.dev)
- [Provider Paketi](https://pub.dev/packages/provider)
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools)
- [iOS App Store Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play Store Guidelines](https://play.google.com/about/developer-content-policy/)

## 🤝 Destek

Sorun yaşarsanız:
1. `flutter doctor -v` çıktısını kontrol edin
2. Backend loglarını kontrol edin
3. Console loglarını kontrol edin
4. GitHub issues'a bakın

---

Başarılar! 🎉 Flutter ile harika bir mobil uygulama geliştirdiniz!


