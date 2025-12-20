# ✅ MVP Shipping Checklist

> Check off items as you complete them. This is your daily progress tracker.

---

## Phase 1: Payment Integration (Days 1-2)
*Without payments, you can't monetize. This is #1 priority.*

### Setup
- [ ] Create RevenueCat account at https://app.revenuecat.com
- [x] Add `purchases_flutter` package to pubspec.yaml ✅
- [x] Run `flutter pub get` ✅

### iOS Setup
- [ ] Create App in App Store Connect
- [ ] Create Subscription Group (e.g., "KuranChat Premium")
- [ ] Create subscription products:
  - [ ] Weekly ($2.99/week)
  - [ ] Monthly ($9.99/month) 
  - [ ] Yearly ($59.99/year - best value)
- [ ] Create Shared Secret in App Store Connect
- [ ] Add Shared Secret to RevenueCat
- [ ] Connect App Store Connect to RevenueCat

### Android Setup
- [ ] Create App in Google Play Console
- [ ] Create subscription products (same pricing)
- [ ] Download Service Account JSON
- [ ] Add Service Account to RevenueCat

### Code Integration
- [x] Initialize RevenueCat in `main.dart` ✅
- [x] Create `SubscriptionService` class ✅
- [x] Connect PaywallScreen to real purchases ✅
- [x] Add restore purchases button ✅
- [x] Handle subscription status throughout app ✅
- [ ] Test purchase flow on real device

---

## Phase 2: User Authentication (Day 3)
*Minimal auth for MVP - device-based is fine*

### Implementation
- [x] Add `flutter_secure_storage` package ✅
- [x] Generate UUID on first app launch ✅
- [x] Store UUID in secure storage ✅
- [x] Send device ID with API requests ✅
- [x] Create user record in backend on first request ✅

### Backend
- [x] Update API to accept device ID header ✅
- [x] Create user if not exists ✅
- [x] Link RevenueCat customer ID to user ✅

---

## Phase 3: Backend Deployment (Days 4-5)
*App needs a live backend to function*

### Choose Platform
- [ ] Option A: Railway (recommended, easy)
- [ ] Option B: Render
- [ ] Option C: Fly.io

### Railway Deployment
- [ ] Create Railway account
- [ ] Create new project
- [ ] Add PostgreSQL database
- [ ] Deploy NestJS backend from GitHub
- [ ] Set environment variables:
  - [ ] `DATABASE_URL`
  - [ ] `OPENAI_API_KEY`
  - [ ] `NODE_ENV=production`
- [ ] Run database migrations
- [ ] Run seed script for Quran data
- [ ] Test API endpoints

### Mobile App Update
- [x] Update `api_config.dart` with production URL ✅
- [ ] Test app against production backend
- [ ] Verify Quran data loads
- [ ] Verify chat works
- [ ] Verify daily content loads

---

## Phase 4: Legal Documents (Day 6)
*Required by Apple and Google - no exceptions*

### Privacy Policy
- [ ] Customize `legal/PRIVACY_POLICY.md` with your info
- [ ] Host on a public URL (GitHub Pages, website, etc.)
- [ ] Test URL is accessible
- [ ] Add URL to App Store Connect
- [ ] Add URL to Google Play Console

### Terms of Service
- [ ] Customize `legal/TERMS_OF_SERVICE.md` with your info
- [ ] Host on same domain as Privacy Policy
- [ ] Test URL is accessible
- [ ] Add URL to stores

---

## Phase 5: Store Assets (Day 6-7)
*Make your listing look professional*

### App Icons
- [ ] Verify iOS icons look correct (no white corners)
- [ ] Verify Android icons look correct
- [ ] Icons are not blurry or pixelated

### Screenshots (iPhone)
- [ ] Home screen (daily content)
- [ ] Quran reader
- [ ] Chat with AI
- [ ] Onboarding/value proposition
- [ ] Community/prayer feature

### Screenshots (Android)
- [ ] Same 5 screens as iOS
- [ ] Correct dimensions for Play Store

### App Descriptions
- [ ] Fill out `store_assets/APP_STORE_INFO.md`
- [ ] Fill out `store_assets/PLAY_STORE_INFO.md`
- [ ] Write compelling short description
- [ ] Write detailed description
- [ ] Add relevant keywords

---

## Phase 6: Testing (Days 8-9)
*Don't skip this - find bugs before users do*

### iOS TestFlight
- [ ] Archive build in Xcode
- [ ] Upload to App Store Connect
- [ ] Add internal testers
- [ ] Test full user flow:
  - [ ] Onboarding completes
  - [ ] Daily content loads
  - [ ] Quran reader works
  - [ ] Chat responds
  - [ ] Purchase flow works
  - [ ] No crashes

### Android Internal Testing
- [ ] Build release APK/AAB
- [ ] Upload to Play Console
- [ ] Add internal testers
- [ ] Test same flow as iOS

### Bug Fixes
- [ ] Fix critical bugs found in testing
- [ ] Re-test fixed issues
- [ ] Get sign-off from testers

---

## Phase 7: Submission (Day 10)
*The finish line!*

### iOS App Store
- [ ] Fill out App Information
- [ ] Upload screenshots
- [ ] Set pricing (free with IAP)
- [ ] Answer export compliance questions
- [ ] Answer content rights questions
- [ ] Submit for review

### Google Play Store
- [ ] Complete store listing
- [ ] Upload screenshots
- [ ] Fill out content rating questionnaire
- [ ] Set up pricing
- [ ] Submit for review

---

## 🎉 Post-Launch

After approval:
- [ ] Monitor crash reports
- [ ] Respond to user reviews
- [ ] Plan v1.1 with push notifications
- [ ] Celebrate! 🎊

---

## Progress Log

| Date | What I Did | Blockers |
|------|------------|----------|
| | | |
| | | |
| | | |


