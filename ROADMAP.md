# Development Roadmap

> **Last Updated:** December 20, 2025  
> **Project Status:** Alpha (UI Complete, Backend Partial)

---

## Current State Summary

| Category | Status | Completion |
|----------|--------|------------|
| UI/UX Design | ✅ Complete | 90% |
| Mobile App (Flutter) | ⚠️ Partial | 70% |
| Backend (NestJS) | ⚠️ Partial | 40% |
| Database | ❌ Minimal | 15% |
| Authentication | ❌ Not Started | 0% |
| Push Notifications | ❌ Not Started | 0% |

---

## ✅ Phase 0: Critical Bug Fixes (COMPLETED)

### Priority 1: Runtime Crashes

- [x] **Fix PaywallScreen animation disposal bug** ✅
  - File: `mobile/lib/screens/onboarding/paywall_screen.dart`
  - Issue: `AnimationController.stop() called after dispose()`
  - Solution: Added `_isDisposed` flag and mounted checks in async animation methods

- [x] **Fix QuranScreen null/encoding errors** ✅
  - File: `mobile/lib/screens/quran_screen.dart`
  - Issue: `type 'Null' is not a subtype of type 'String'`
  - Solution: Added `_safeString()` helper with UTF-16 sanitization and null handling

- [x] **Fix SVG style tag warnings** ✅
  - Files: `assets/PaywallAnimation/NeverMissaMomentofFaith.svg`
  - Issue: `unhandled element <style/>`
  - Solution: Converted CSS class `.st0` to inline `fill="#fff"` attributes

### Priority 2: Performance Issues

- [ ] **Reduce GPU overload from blur effects**
  - Issue: `Could not acquire current drawable` errors
  - Solution: Reduce `BackdropFilter` usage or lower blur sigma values
  - Affected screens: All screens with glassmorphism
  - Status: Deferred to Phase 6 (optimization)

- [x] **Update outdated dependencies** ✅
  - Updated: `share_plus` 7.x → 10.x, `flutter_lints` 3.x → 4.x, `dio` 5.4 → 5.7, etc.
  - SDK constraint updated to `>=3.3.0 <4.0.0`

---

## ✅ Phase 1: Core Data Foundation (COMPLETED)

### 1.1 Complete Quran Database ✅

- [x] Import script completed successfully
- [x] **6,236 verses imported (100% coverage)**
- [x] Turkish translations (Diyanet Vakfı Meali)
- [x] Arabic text with proper tashkeel (Uthmani script)
- [x] All 114 surahs with metadata

**Import completed on:** December 19, 2025
```
✅ Total verses: 6,236/6,236 (100%)
⏱️ Duration: 1.2 minutes
```

### 1.2 Daily Content System ✅

- [x] API endpoint: `GET /api/daily` - Returns verse, tafsir, prayer
- [x] Daily rotation based on day of year
- [x] Hijri date calculation included
- [x] Mobile app now fetches from API via `DailyContentService`
- [x] Fallback to hardcoded data if API unavailable

**Files Updated:**
```
mobile/lib/widgets/home/daily_journey_card.dart  ← Now uses DailyContentService
mobile/lib/screens/home_screen.dart              ← Fetches content on init
```

### 1.3 Quran Reader API ✅

- [x] `GET /api/quran/surahs` - List all 114 surahs
- [x] `GET /api/quran/surah/:number` - Get full surah with verses
- [x] `GET /api/quran/surah/:surah/ayah/:ayah` - Get single verse
- [x] `GET /api/quran/search?q=:query` - Search verses
- [x] `GET /api/quran/stats` - Database coverage statistics
- [x] `GET /api/quran/featured` - Popular verses (Ayetel Kursi, etc.)
- [x] Mobile QuranScreen already connected to API

### 1.4 Reading Progress Tracking ✅ (Bonus)

- [x] `ReadingProgressService` - Local progress storage
- [x] Surah list shows progress percentage for each surah
- [x] Progress bar under each surah with partial progress
- [x] Checkmark badge for completed surahs
- [x] Automatic tracking as user scrolls through verses
- [x] Last read position saved

**Files Added:**
```
mobile/lib/services/reading_progress_service.dart  ← New service
mobile/lib/screens/quran_screen.dart               ← Updated with progress UI
```

---

## 📅 Phase 2: User System (Week 3-4)

### 2.1 Anonymous Authentication

- [ ] Generate device UUID on first launch
- [ ] Store in secure storage (flutter_secure_storage)
- [ ] Create `User` table in database
- [ ] Create `/api/user/register-device` endpoint

### 2.2 User Progress Tracking

- [ ] Create `UserProgress` database table
- [ ] Track: `lastReadSurah`, `lastReadAyah`, `completedSurahs`
- [ ] Track: `streak`, `xp`, `level`, `totalVersesRead`
- [ ] Build `/api/user/progress` endpoints

### 2.3 Connect Profile Screen

- [ ] Replace mock data with real user stats
- [ ] Implement streak calculation logic
- [ ] Show real achievements based on progress

**Files to Update:**
```
mobile/lib/screens/profile_screen.dart
mobile/lib/providers/user_provider.dart  ← Create this
```

---

## 📅 Phase 3: Enhanced Content (Week 5-6)

### 3.1 Tafsir (Commentary) System

- [ ] Create `Tafsir` database table
- [ ] Import Ibn Kesir tafsir (Turkish)
- [ ] Import Diyanet tefsir
- [ ] Build `/api/tafsir/:surah/:ayah` endpoint
- [ ] Integrate into Quran reader screen

### 3.2 Prayers (Dua) Collection

- [ ] Create `Prayer` database table
- [ ] Curate 100+ prayers (Quranic + traditional)
- [ ] Categorize: morning, evening, travel, etc.
- [ ] Build `/api/prayers` endpoints

### 3.3 Bookmarks & Favorites

- [ ] Create `Bookmark` database table
- [ ] Add bookmark button to verse cards
- [ ] Create favorites screen in profile
- [ ] Sync across sessions

### 3.4 Search Functionality

- [ ] Full-text search in Turkish translations
- [ ] Arabic text search
- [ ] Search history
- [ ] Search suggestions

---

## 📅 Phase 4: Community Features (Week 7-8)

### 4.1 Chat History Persistence

- [ ] Store conversations in database
- [ ] Load chat history from API
- [ ] Implement conversation deletion

**Files to Update:**
```
mobile/lib/screens/chat_screen.dart  ← Lines 28-56 (mock history)
```

### 4.2 Prayer Requests (Basic)

- [ ] Create `PrayerRequest` database table
- [ ] Submit prayer request feature
- [ ] View community prayers
- [ ] "Amin" counter functionality

### 4.3 Live Prayer Rooms (Advanced)

- [ ] WebSocket integration
- [ ] Real-time presence system
- [ ] Live prayer broadcast
- [ ] Participant list

---

## 📅 Phase 5: Engagement & Retention (Week 9-10)

### 5.1 Push Notifications

- [ ] Setup Firebase Cloud Messaging (FCM)
- [ ] Configure Apple Push Notification Service (APNs)
- [ ] Daily verse reminder
- [ ] Streak reminder (if not opened by evening)
- [ ] Community prayer invitations

### 5.2 Home Screen Widget

- [ ] iOS Widget Extension
- [ ] Android App Widget
- [ ] Display verse of the day
- [ ] Quick prayer times

### 5.3 Offline Mode

- [ ] Cache frequently accessed surahs
- [ ] Store user preferences locally
- [ ] Queue actions for sync when online
- [ ] Download surahs for offline reading

---

## 📅 Phase 6: Polish & Launch (Week 11-12)

### 6.1 Performance Optimization

- [ ] Lazy loading for long lists
- [ ] Image caching & compression
- [ ] Reduce unnecessary rebuilds
- [ ] Profile and fix memory leaks

### 6.2 Analytics Integration

- [ ] Firebase Analytics setup
- [ ] Track key events:
  - Daily active users
  - Verses read per day
  - Chat questions asked
  - Popular surahs
  - Streak patterns

### 6.3 App Store Preparation

- [ ] App icons (all sizes)
- [ ] Screenshots for store listing
- [ ] Privacy policy
- [ ] Terms of service
- [ ] App Store / Play Store descriptions

### 6.4 Beta Testing

- [ ] TestFlight setup (iOS)
- [ ] Internal testing track (Android)
- [ ] Gather user feedback
- [ ] Fix reported issues

---

## 🎯 Success Metrics

| Metric | Target (Launch) | Target (3 Months) |
|--------|-----------------|-------------------|
| Daily Active Users | 100 | 5,000 |
| Average Session Duration | 3 min | 8 min |
| 7-Day Retention | 30% | 45% |
| Verses Read/Day (avg) | 5 | 15 |
| Chat Questions/Day | 50 | 500 |
| App Store Rating | 4.0 | 4.5 |

---

## 🔧 Technical Debt to Address

| Issue | Priority | Effort |
|-------|----------|--------|
| Remove all hardcoded content | High | Medium |
| Add comprehensive error handling | High | Medium |
| Write unit tests (0% coverage) | Medium | High |
| Add integration tests | Medium | High |
| Refactor duplicate glassmorphism code | Low | Low |
| Create shared widget library | Low | Medium |
| Add logging/monitoring | Medium | Low |

---

## 📁 Key Files Reference

### Mobile App
```
lib/
├── main.dart
├── screens/
│   ├── chat_screen.dart        ← Needs API integration
│   ├── quran_screen.dart       ← Has null safety bugs
│   ├── home_screen.dart
│   ├── profile_screen.dart     ← Needs real user data
│   └── onboarding/
│       └── paywall_screen.dart ← Has animation bugs
├── providers/
│   └── chat_provider.dart
├── services/
│   ├── api_service.dart
│   └── api_config.dart
└── widgets/
    └── home/
        └── daily_journey_card.dart ← Needs API data
```

### Backend
```
backend/
├── src/
│   ├── chat/
│   │   ├── chat.service.ts
│   │   ├── quran.controller.ts
│   │   └── daily.controller.ts
│   └── prisma/
│       └── prisma.service.ts
├── prisma/
│   ├── schema.prisma          ← Add new tables here
│   └── seed.ts
└── scripts/
    ├── import-quran.ts        ← Enhance for full import
    └── import-tafsir.ts
```

---

## 📞 Resources & APIs

| Resource | URL | Purpose |
|----------|-----|---------|
| Quran.com API | https://api.quran.com/api/v4/ | Quran text & translations |
| Al-Quran Cloud | https://alquran.cloud/api | Alternative Quran API |
| Aladhan API | https://aladhan.com/prayer-times-api | Prayer times & Hijri calendar |
| Tanzil.net | http://tanzil.net/download/ | Verified Quran text files |

---

## ✅ Completed Milestones

- [x] Onboarding flow (8 steps)
- [x] Home screen with daily cards
- [x] Chat interface with AI responses
- [x] Design system - Glassmorphism 
- [x] Navigation with 5 tabs
- [x] Share to Instagram Stories
- [x] Basic Quran reader screen
- [x] Profile screen with gamification UI
- [x] Community screen layout

---

*This roadmap is a living document. Update as priorities change.*
