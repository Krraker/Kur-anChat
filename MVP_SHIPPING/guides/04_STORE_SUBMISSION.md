# 📱 App Store Submission Guide

> Step-by-step guide to submitting to iOS App Store and Google Play Store.

---

## Before You Submit

### Prerequisites Checklist

- [ ] RevenueCat integration working
- [ ] Backend deployed and accessible
- [ ] Privacy Policy URL live
- [ ] Terms of Service URL live
- [ ] App icons correct (no white corners on iOS)
- [ ] Screenshots ready
- [ ] App tested on real devices
- [ ] No crashes in 30 minutes of use

---

## Part 1: iOS App Store

### Step 1: Xcode Setup

```bash
cd /Users/cemyonetim/Development/KuranChat/mobile/ios
```

1. Open `Runner.xcworkspace` in Xcode
2. Select "Runner" in project navigator
3. Go to "Signing & Capabilities" tab
4. Select your Team (Apple Developer Account)
5. Ensure Bundle Identifier is unique (e.g., `com.yourcompany.kuranchat`)

### Step 2: Update Version

In `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version+build_number
```

Then run:
```bash
cd /Users/cemyonetim/Development/KuranChat/mobile
flutter build ios --release
```

### Step 3: Archive & Upload

1. In Xcode: Product → Archive
2. Wait for archive to complete
3. Window → Organizer
4. Select your archive → "Distribute App"
5. Choose "App Store Connect"
6. Follow prompts to upload

### Step 4: App Store Connect Setup

Go to https://appstoreconnect.apple.com

#### App Information
- **Name:** Kuran Chat (or your app name)
- **Subtitle:** AI Quran Assistant (max 30 chars)
- **Primary Language:** Turkish
- **Category:** Reference (or Lifestyle)
- **Secondary Category:** Education

#### Pricing
- **Price:** Free
- **In-App Purchases:** Yes (configured in RevenueCat step)

#### Privacy
- **Privacy Policy URL:** `https://yoursite.com/privacy`
- **Data Collection:** Select what your app collects

#### App Privacy Questions
Answer honestly:
- Identifiers: Device ID (for analytics)
- Usage Data: Product Interaction (verse reading)
- Purchases: Purchase History

#### Age Rating
Fill out the questionnaire:
- No violence, gambling, etc.
- Religious content: Yes
- Result will be 4+ or 12+ typically

### Step 5: Upload Screenshots

Required sizes:
- **6.7" iPhone** (1290 x 2796px) - iPhone 15 Pro Max
- **6.5" iPhone** (1284 x 2778px) - iPhone 14 Plus
- **5.5" iPhone** (1242 x 2208px) - iPhone 8 Plus
- **iPad Pro 12.9"** (2048 x 2732px) - if supporting iPad

Recommended screenshots:
1. Home screen with daily content
2. Quran reader
3. AI Chat feature
4. Onboarding/value proposition
5. Community feature

### Step 6: Submit for Review

1. Go to your app version
2. Add "What's New" text (for updates)
3. Fill in Review Notes (optional but helpful):
   ```
   Test Account: Not required (anonymous auth)
   In-App Purchase: Uses sandbox testing
   Notes: This is a Quran reading and AI assistant app.
   ```
4. Click "Submit for Review"

### Review Timeline
- Typical: 24-48 hours
- Sometimes: Up to 1 week
- Rejection reasons are usually clear and fixable

---

## Part 2: Google Play Store

### Step 1: Build Release APK/AAB

```bash
cd /Users/cemyonetim/Development/KuranChat/mobile

# Build App Bundle (recommended)
flutter build appbundle --release

# Or APK
flutter build apk --release
```

Output location:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/apk/release/app-release.apk`

### Step 2: Sign Your App

If first time, create keystore:
```bash
keytool -genkey -v -keystore ~/kuranchat-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias kuranchat
```

Create `android/key.properties`:
```properties
storePassword=<your password>
keyPassword=<your password>
keyAlias=kuranchat
storeFile=/Users/cemyonetim/kuranchat-keystore.jks
```

Update `android/app/build.gradle.kts`:
```kotlin
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 3: Google Play Console Setup

Go to https://play.google.com/console

#### Create App
- **App name:** Kuran Chat
- **Default language:** Turkish
- **App type:** App
- **Free/Paid:** Free

#### Store Listing

**Short Description** (80 chars max):
```
Kur'an okuyun, AI asistanıyla sorularınızı sorun.
```

**Full Description** (4000 chars max):
See `store_assets/PLAY_STORE_INFO.md`

#### Graphics
- **App Icon:** 512 x 512 PNG
- **Feature Graphic:** 1024 x 500 PNG
- **Screenshots:** Min 2, Max 8 per device type
  - Phone: 16:9 or 9:16 ratio
  - Tablet: 16:9 or 9:16 ratio

### Step 4: Content Rating

1. Go to Policy → App content → Content rating
2. Fill out IARC questionnaire
3. Answer honestly about content
4. Receive rating (likely Everyone or Everyone 10+)

### Step 5: Data Safety

1. Go to Policy → App content → Data safety
2. Declare what data you collect:
   - Device identifiers (for anonymous auth)
   - App activity (verses read)
   - Purchase history

### Step 6: Create Release

1. Go to Release → Production
2. Click "Create new release"
3. Upload your AAB file
4. Add release notes
5. Review and rollout

### Step 7: Submit for Review

1. Complete all checklist items
2. Submit for review
3. Timeline: Usually 1-3 days, can be up to a week

---

## Common Rejection Reasons

### iOS Rejections

| Reason | Fix |
|--------|-----|
| Broken functionality | Test all features thoroughly |
| Privacy policy missing | Add URL in App Store Connect |
| In-app purchase issues | Test in sandbox mode |
| Misleading description | Match description to actual app |
| Crashes | Fix bugs, test on multiple devices |

### Android Rejections

| Reason | Fix |
|--------|-----|
| Policy violation | Read policies carefully |
| Deceptive behavior | Be transparent about features |
| Permission issues | Only request needed permissions |
| Broken functionality | Test on multiple Android versions |

---

## Post-Submission

### While Waiting
- Prepare marketing materials
- Set up analytics dashboard
- Create social media accounts
- Plan launch announcement

### After Approval
- Monitor crash reports (Firebase Crashlytics)
- Respond to user reviews
- Track download numbers
- Plan v1.1 features

---

## Timeline Summary

| Task | Duration |
|------|----------|
| Prepare builds | 1 day |
| Fill out store listings | 1 day |
| Create screenshots | 1 day |
| Submit iOS | 1 day |
| Submit Android | 1 day |
| iOS Review | 1-7 days |
| Android Review | 1-3 days |
| **Total** | **5-14 days** |

---

*Congratulations on reaching submission! 🎉*




