# Ayet Rehberi - Flutter Mobile App

Flutter ile geliştirilmiş iOS ve Android mobil uygulaması.

## 🎯 Özellikler

- ✅ WhatsApp tarzı sohbet arayüzü
- ✅ Gerçek zamanlı mesajlaşma
- ✅ Güzel ayet gösterimi (Arapça + Türkçe)
- ✅ Örnek soru önerileri
- ✅ Loading durumları ve animasyonlar
- ✅ Hata yönetimi
- ✅ Provider ile state management
- ✅ Material Design 3
- ✅ iOS ve Android desteği

## 📱 Ekran Görüntüleri

- Ana sohbet ekranı
- Mesaj balonları (kullanıcı ve asistan)
- Ayet kartları
- Boş durum ekranı

## 🚀 Kurulum

### Gereksinimler

- Flutter 3.0+
- Dart 3.0+
- iOS: Xcode 14+, iOS 12+
- Android: Android Studio, API 21+

### Flutter Kurulumu

Flutter yüklü değilse:

```bash
# macOS
brew install --cask flutter

# veya https://docs.flutter.dev/get-started/install adresinden indirin
```

Flutter'ın kurulu olduğunu doğrulayın:

```bash
flutter doctor
```

### Proje Kurulumu

1. Bağımlılıkları yükleyin:

```bash
cd mobile
flutter pub get
```

2. Backend URL'ini ayarlayın:

`lib/services/api_service.dart` dosyasında `baseUrl` değişkenini düzenleyin:

```dart
// iOS Simulator için
static const String baseUrl = 'http://localhost:3001/api';

// Android Emulator için
static const String baseUrl = 'http://10.0.2.2:3001/api';

// Fiziksel cihaz için (bilgisayarınızın IP'sini kullanın)
static const String baseUrl = 'http://192.168.1.X:3001/api';
```

3. Uygulamayı çalıştırın:

```bash
# iOS için
flutter run -d ios

# Android için
flutter run -d android

# veya cihaz seçmek için
flutter devices
flutter run -d <device-id>
```

## 📁 Proje Yapısı

```
mobile/
├── lib/
│   ├── main.dart              # Uygulama giriş noktası
│   ├── models/                # Veri modelleri
│   │   ├── conversation.dart
│   │   ├── message.dart
│   │   └── quran_verse.dart
│   ├── providers/             # State management
│   │   └── chat_provider.dart
│   ├── screens/               # Ekranlar
│   │   └── chat_screen.dart
│   ├── services/              # API servisleri
│   │   └── api_service.dart
│   └── widgets/               # UI bileşenleri
│       ├── chat_input.dart
│       ├── empty_state.dart
│       ├── message_bubble.dart
│       └── verse_card.dart
├── pubspec.yaml               # Dependencies
└── analysis_options.yaml      # Linter kuralları
```

## 🏗️ Mimari

### State Management
- **Provider**: Basit ve etkili state management
- **ChatProvider**: Mesaj yönetimi ve API çağrıları

### Servis Katmanı
- **ApiService**: Backend ile iletişim
- REST API çağrıları
- HTTP client (http package)

### Veri Modelleri
- **Message**: Kullanıcı ve asistan mesajları
- **QuranVerse**: Kuran ayetleri
- **Conversation**: Sohbet geçmişi

## 🎨 UI Bileşenleri

### ChatScreen
Ana sohbet ekranı:
- Mesaj listesi
- Auto-scroll
- Loading göstergesi
- AppBar ile başlık

### MessageBubble
Mesaj baloncukları:
- Kullanıcı mesajları: Yeşil, sağda
- Asistan mesajları: Beyaz, solda
- Animasyonlu giriş

### VerseCard
Ayet kartları:
- Arapça metin (sağdan sola)
- Türkçe çeviri
- Sure:Ayet referansı
- Yeşil sol border

### ChatInput
Mesaj giriş alanı:
- Çok satırlı metin girişi
- Gönder butonu
- Dinamik yükseklik

### EmptyState
Boş durum ekranı:
- Hoş geldin mesajı
- Örnek soru butonları
- Güzel icon

## 🔧 Yapılandırma

### Backend Bağlantısı

`lib/services/api_service.dart` içinde:

```dart
// Development
static const String baseUrl = 'http://localhost:3001/api';

// Production
static const String baseUrl = 'https://your-api.com/api';
```

### Renkler

`lib/main.dart` içinde Material tema:

```dart
colorScheme: ColorScheme.fromSeed(
  seedColor: const Color(0xFF22c55e), // Ana yeşil renk
  brightness: Brightness.light,
),
```

### Font

Google Fonts kullanılıyor (Inter):

```dart
textTheme: GoogleFonts.interTextTheme(),
```

## 📦 Bağımlılıklar

Ana paketler:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1          # State management
  http: ^1.1.2              # HTTP istekleri
  dio: ^5.4.0               # Alternatif HTTP client
  google_fonts: ^6.1.0      # Font'lar
  shared_preferences: ^2.2.2 # Local storage
  uuid: ^4.3.3              # UUID üretimi
  intl: ^0.19.0             # Tarih formatlama
```

## 🚀 Build & Release

### Android APK

```bash
flutter build apk --release
```

APK konumu: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Xcode ile imzalama yapın ve App Store'a yükleyin.

### App Bundle (Android)

```bash
flutter build appbundle --release
```

## 🧪 Test

```bash
# Widget testleri
flutter test

# Integration testleri
flutter drive --target=test_driver/app.dart
```

## 📱 Platform Özellikleri

### iOS
- Cupertino widgets uyumlu
- Safe area desteği
- iOS scroll physics

### Android
- Material Design 3
- Android navigasyon
- Back button desteği

## 🔮 Gelecek Özellikler

Eklenebilecek özellikler:

- [ ] Sohbet geçmişi ekranı
- [ ] Favorilere ekleme
- [ ] Arama fonksiyonu
- [ ] Karanlık mod
- [ ] Sesli okuma (Text-to-Speech)
- [ ] Paylaşma özelliği
- [ ] Push notifications
- [ ] Offline desteği
- [ ] Çoklu dil desteği
- [ ] Ayarlar sayfası

## 🛠️ Geliştirme

### Hot Reload

Kod değişikliklerini anında görmek için:

```bash
# Uygulamayı çalıştırın
flutter run

# Terminalde:
r  # Hot reload
R  # Hot restart
q  # Quit
```

### Debug Mode

```bash
flutter run --debug
```

### Release Mode

```bash
flutter run --release
```

### Profiling

```bash
flutter run --profile
```

## 🐛 Hata Ayıklama

### Backend bağlantı hatası

**Hata:** "SocketException: Failed to connect"

**Çözüm:**
- Backend'in çalıştığından emin olun
- URL'yi doğru platformda ayarlayın:
  - iOS Simulator: `localhost`
  - Android Emulator: `10.0.2.2`
  - Fiziksel cihaz: Bilgisayar IP adresi
- Firewall ayarlarını kontrol edin

### Build hatası

```bash
# Clean ve yeniden build
flutter clean
flutter pub get
flutter run
```

### iOS Simulator bulunamıyor

```bash
# Simulator'leri listele
xcrun simctl list

# Simulator başlat
open -a Simulator
```

### Android Emulator başlamıyor

```bash
# Emulator'leri listele
flutter emulators

# Emulator başlat
flutter emulators --launch <emulator-id>
```

## 📱 Fiziksel Cihazda Test

### iOS

1. iPhone'u Mac'e bağlayın
2. Xcode'da Developer hesabınızı ekleyin
3. `flutter run` komutunu çalıştırın

### Android

1. Telefonda Developer Options'ı açın
2. USB Debugging'i aktif edin
3. Telefonu bilgisayara bağlayın
4. `flutter run` komutunu çalıştırın

## 🌐 Backend Bağlantısı

Backend'in çalışıyor olması gerekir:

```bash
# Backend terminali
cd backend
npm run start:dev
```

Backend URL: `http://localhost:3001/api`

## 📖 Daha Fazla Bilgi

- [Flutter Dokümantasyonu](https://docs.flutter.dev)
- [Provider Paketi](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines)

## 🤝 Katkıda Bulunma

Ana CONTRIBUTING.md dosyasına bakın.

## 📄 Lisans

MIT

---

**Not:** Backend API'nin çalışıyor olması gerektiğini unutmayın!

Keyifli kodlamalar! 🚀


