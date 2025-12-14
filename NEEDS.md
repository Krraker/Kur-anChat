# Kur'an Chat - Implementation Requirements

## 📊 Current State Overview

### ✅ Implemented (UI Complete)
- Onboarding flow (language, age, mezhep, translation, goals, interests, widget setup, journey preview, paywall)
- Home screen with daily journey cards (Günün Ayeti, Kişisel Tefsir, Günün Duası)
- Chat interface with AI responses
- Community screen with live prayer room
- Profile screen with gamification UI
- Quran reader screen (basic)
- Navigation with 5 tabs
- Share to Instagram Stories feature
- Glassmorphism design system

### ⚠️ Partially Implemented
- Chat with GPT (works but uses hardcoded/sample verses)
- Quran verses display (only ~10 sample verses in database)

### ❌ Not Implemented (Backend/Data Required)
- Full Quran database (6236 verses)
- User authentication
- User progress tracking
- Real-time community features
- Push notifications
- Daily verse rotation
- Tafsir content

---

## 🗄️ Database Requirements

### 1. Complete Quran Database
**Current State:** Only ~10 sample verses in `QuranVerse` table
**Required:** All 6236 verses

```sql
-- Required data for each verse:
- surah (1-114)
- surah_name (Arabic & Turkish)
- ayah (verse number)
- text_ar (Arabic text with tashkeel)
- text_tr (Turkish translation - Diyanet)
- juz (1-30)
- page (1-604)
- hizb (1-60)
```

**Data Sources:**
- [Quran.com API](https://api.quran.com/api/v4/)
- [Al-Quran Cloud API](https://alquran.cloud/api)
- [Tanzil.net](http://tanzil.net/download/) - Free Quran text files

### 2. Tafsir Database (New Table)
```prisma
model Tafsir {
  id        Int      @id @default(autoincrement())
  surah     Int
  ayah      Int
  source    String   // "Ibn Kesir", "Taberi", "Diyanet" etc.
  text_tr   String   @db.Text
  
  @@unique([surah, ayah, source])
  @@map("tafsirs")
}
```

### 3. User Profile (New Table)
```prisma
model User {
  id              String   @id @default(uuid())
  deviceId        String?  @unique
  email           String?  @unique
  name            String?
  language        String   @default("tr")
  selectedMezhep  String?
  translation     String   @default("diyanet")
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  
  progress        UserProgress?
  preferences     UserPreferences?
  conversations   Conversation[]
  
  @@map("users")
}
```

### 4. User Progress (New Table)
```prisma
model UserProgress {
  id              String   @id @default(uuid())
  userId          String   @unique
  user            User     @relation(fields: [userId], references: [id])
  
  // Reading progress
  lastReadSurah   Int      @default(1)
  lastReadAyah    Int      @default(1)
  completedSurahs Int[]    @default([])
  
  // Gamification
  level           Int      @default(1)
  xp              Int      @default(0)
  streak          Int      @default(0)
  lastActiveDate  DateTime @default(now())
  
  // Stats
  totalVersesRead Int      @default(0)
  totalTimeSpent  Int      @default(0) // in minutes
  
  @@map("user_progress")
}
```

### 5. Daily Content (New Table)
```prisma
model DailyContent {
  id          Int      @id @default(autoincrement())
  date        DateTime @unique @db.Date
  
  // Verse of the day
  verseSurah  Int
  verseAyah   Int
  
  // Featured prayer
  prayerId    Int?
  
  // Tafsir highlight
  tafsirId    Int?
  
  @@map("daily_content")
}
```

### 6. Prayers Collection (New Table)
```prisma
model Prayer {
  id        Int      @id @default(autoincrement())
  arabic    String   @db.Text
  turkish   String   @db.Text
  source    String?  // "Quran", "Hadis", "Gelenek"
  occasion  String?  // "Sabah", "Akşam", "Yolculuk" etc.
  
  @@map("prayers")
}
```

---

## 🔌 API Endpoints Required

### Daily Content
```
GET /api/daily
Response: {
  verseOfDay: { surah, ayah, arabic, turkish, surahName },
  tafsir: { text, source },
  prayer: { arabic, turkish },
  hijriDate: "1446-06-15",
  gregorianDate: "2024-12-08"
}
```

### Quran Reading
```
GET /api/quran/surah/:number
GET /api/quran/surah/:surah/ayah/:ayah
GET /api/quran/juz/:number
GET /api/quran/page/:number
GET /api/quran/search?q=:query
```

### User Progress
```
GET  /api/user/progress
POST /api/user/progress/verse-read
POST /api/user/progress/update-streak
GET  /api/user/achievements
```

### Tafsir
```
GET /api/tafsir/:surah/:ayah
GET /api/tafsir/:surah/:ayah?source=ibn-kesir
```

---

## 📱 Mobile App Requirements

### 1. API Integration
Replace hardcoded `DailyContent` class with API calls:

```dart
// services/daily_content_service.dart
class DailyContentService {
  Future<DailyVerseResponse> getVerseOfDay();
  Future<TafsirResponse> getTafsir(int surah, int ayah);
  Future<PrayerResponse> getRandomPrayer();
}
```

### 2. Quran Reader Service
```dart
// services/quran_service.dart
class QuranService {
  Future<List<Surah>> getAllSurahs();
  Future<Surah> getSurah(int number);
  Future<Verse> getVerse(int surah, int ayah);
  Future<List<Verse>> searchVerses(String query);
}
```

### 3. User Progress Service
```dart
// services/user_progress_service.dart
class UserProgressService {
  Future<UserProgress> getProgress();
  Future<void> markVerseAsRead(int surah, int ayah);
  Future<void> updateStreak();
  Future<List<Achievement>> getAchievements();
}
```

### 4. Local Storage
```dart
// For offline access
- Cache frequently accessed surahs
- Store user preferences locally
- Queue verse reads for sync when online
```

---

## 🔐 Authentication Options

### Option A: Anonymous (Device-Based)
- Generate UUID on first launch
- Store in secure storage
- No signup required
- Limited cross-device sync

### Option B: Email/Password
- Standard auth flow
- Password reset
- Email verification

### Option C: Social Login
- Apple Sign In (required for iOS)
- Google Sign In
- Optional

### Recommended: Hybrid
1. Start anonymous (device ID)
2. Prompt to create account for sync/backup
3. Support Apple/Google for easy onboarding

---

## 🔔 Push Notifications

### Use Cases
1. Daily verse reminder (customizable time)
2. Streak reminder (evening if not opened)
3. Community prayer invitations
4. Weekly progress summary

### Implementation
- Firebase Cloud Messaging (FCM)
- Apple Push Notification Service (APNs)
- Backend notification scheduler

---

## 📅 Content Scheduler

### Daily Rotation System
```typescript
// Backend cron job
@Cron('0 0 * * *') // Midnight
async rotateDailyContent() {
  // Select new verse of the day
  // Select featured tafsir
  // Select daily prayer
  // Update DailyContent table
}
```

---

## 🌐 Community Features (Phase 2)

### Required Tables
```prisma
model PrayerRequest {
  id        String   @id @default(uuid())
  userId    String
  content   String   @db.Text
  isPublic  Boolean  @default(true)
  aminCount Int      @default(0)
  createdAt DateTime @default(now())
  
  @@map("prayer_requests")
}

model LivePrayerSession {
  id           String   @id @default(uuid())
  hostUserId   String
  prayerText   String   @db.Text
  scheduledFor DateTime
  isActive     Boolean  @default(false)
  
  @@map("live_prayer_sessions")
}
```

### Real-time Requirements
- WebSocket connection for live prayers
- Presence system (online users)
- Real-time amin counter

---

## 📊 Analytics (Phase 2)

### Track
- Daily active users
- Verses read per day
- Chat questions asked
- Popular surahs
- Streak patterns
- Feature usage

### Tools
- Firebase Analytics (free)
- Mixpanel (paid, better insights)
- Custom backend analytics

---

## 🎯 Priority Implementation Order

### Phase 1: Core Data (Week 1-2)
1. ✅ Import complete Quran database (6236 verses)
2. ✅ Create daily content rotation system
3. ✅ Build Quran reading API
4. ✅ Connect mobile app to real data

### Phase 2: User Features (Week 3-4)
1. User authentication (device-based first)
2. Reading progress tracking
3. Streak system
4. Local caching for offline

### Phase 3: Enhanced Content (Week 5-6)
1. Tafsir database import
2. Prayers collection
3. Search functionality
4. Bookmarks/favorites

### Phase 4: Community (Week 7-8)
1. Prayer requests
2. Live prayer rooms (real backend)
3. User profiles (public)
4. Push notifications

### Phase 5: Polish (Week 9-10)
1. Performance optimization
2. Offline mode
3. Widget for iOS/Android
4. Analytics

---

## 🔗 External APIs to Consider

### Quran Data
- **Quran.com API** - Free, comprehensive, multiple translations
- **Al-Quran Cloud** - Free, simple, good for basics

### Islamic Calendar
- **Aladhan API** - Prayer times + Hijri calendar
- **Islamic Network API** - Hijri date conversion

### Audio (Future)
- **Quran.com Audio** - Recitation by famous Qaris
- **EveryAyah.com** - Verse-by-verse audio

---

## 📁 Data Import Scripts Needed

```bash
# scripts/import-quran.ts
# - Fetch from Quran.com API
# - Import all 114 surahs
# - Include Arabic + Turkish translation

# scripts/import-tafsir.ts
# - Import Ibn Kesir tafsir (Turkish)
# - Import Diyanet tefsir

# scripts/import-prayers.ts
# - Common Quranic prayers
# - Daily prayers collection
```

---

## ⚡ Quick Wins

1. **Replace hardcoded verses** - Use existing DB verses in DailyContent
2. **Add more sample verses** - Seed script with 100+ popular verses
3. **Randomize daily content** - Simple rotation without full system
4. **Cache API responses** - Reduce load, improve speed

---

## 📞 Contact for Data Sources

- **Diyanet İşleri Başkanlığı** - Official Turkish translations
- **Islamic Foundation** - Open source Quran data
- **Tanzil Project** - Verified Quran text files

---

*Last Updated: December 2024*
