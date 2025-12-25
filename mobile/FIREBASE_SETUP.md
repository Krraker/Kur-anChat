# Firebase Setup Instructions

## What You Need

Firebase Analytics requires a Firebase project and configuration files for iOS and Android.

## Steps to Complete Firebase Setup

### 1. Create Firebase Project (5 minutes)

1. Go to https://console.firebase.google.com
2. Click "Add Project"
3. Name: "Kur'an Chat" or "AyetRehberi"
4. Enable Google Analytics: YES
5. Use default Analytics account
6. Click "Create Project"

### 2. Add iOS App (5 minutes)

1. In Firebase Console → Click iOS icon
2. iOS bundle ID: Get it from Xcode
   ```bash
   # Find your bundle ID:
   open /Users/cemyonetim/Development/KuranChat/mobile/ios/Runner.xcodeproj
   # In Xcode: Runner → General → Bundle Identifier
   ```
3. Download `GoogleService-Info.plist`
4. Place it here: `/Users/cemyonetim/Development/KuranChat/mobile/ios/Runner/GoogleService-Info.plist`
5. In Xcode: Right-click Runner folder → Add Files → Select `GoogleService-Info.plist`

### 3. Add Android App (Future - Optional)

1. In Firebase Console → Click Android icon
2. Android package name: Same as iOS bundle ID
3. Download `google-services.json`
4. Place it here: `/Users/cemyonetim/Development/KuranChat/mobile/android/app/google-services.json`

## Quick Alternative: Mock Analytics (For Testing Now)

If you want to test the app immediately without Firebase setup, analytics will just print to console.

The app will work fine - analytics events will be logged locally but not sent to Firebase.

## After Firebase Setup

Once you have `GoogleService-Info.plist`:

```bash
cd /Users/cemyonetim/Development/KuranChat/mobile
flutter run
```

The app will:
- ✅ Track all analytics events
- ✅ Send to Firebase Console
- ✅ Show real-time data

## View Analytics

After setup, view analytics at:
https://console.firebase.google.com/u/0/project/YOUR_PROJECT/analytics

You'll see:
- Real-time active users
- Event tracking (chat_limit_reached, upgrade_button_clicked, etc.)
- Conversion funnels
- User retention

---

**For now, let's test the app locally without Firebase**. Analytics will work, just won't send data.

