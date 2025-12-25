# Free Tier Chat Limits - Implementation Guide

> **Goal:** Limit free users to 5 AI chat messages per day  
> **Premium:** Unlimited messages  
> **Implementation Time:** 2-3 hours

---

## 📊 Strategy Overview

### Free Tier
- ✅ 5 AI chat messages per day
- ✅ Resets at midnight (local time)
- ✅ All other features unlimited (reading, daily verse, etc.)

### Premium Tier (Paid Subscription)
- ✅ Unlimited AI chat messages
- ✅ Priority responses (faster)
- ✅ Exclusive tafsir content
- ✅ Advanced features (coming soon)

### Why 5 Messages?
- Enough to be useful and build habit
- Creates urgency to upgrade
- Industry standard (ChatGPT uses 3-5 for free tier)
- Low OpenAI cost (<$1/user/month)

---

## 🗄️ Step 1: Update Database Schema

### Add Message Tracking to User Model

Update `backend/prisma/schema.prisma`:

```prisma
model User {
  id              String   @id @default(uuid())
  deviceId        String?  @unique @map("device_id")
  email           String?  @unique
  name            String?
  language        String   @default("tr")
  selectedMezhep  String?  @map("selected_mezhep")
  translation     String   @default("diyanet")
  
  // ⭐ NEW: Chat usage tracking
  dailyMessageCount    Int      @default(0) @map("daily_message_count")
  dailyMessageResetAt  DateTime @default(now()) @map("daily_message_reset_at")
  isPremium            Boolean  @default(false) @map("is_premium")
  
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")

  progress        UserProgress?

  @@map("users")
}
```

### Run Migration

```bash
cd backend
npx prisma migrate dev --name add_chat_limits
```

---

## 🔧 Step 2: Update Backend Chat Service

### Update `backend/src/chat/chat.service.ts`

Add limit checking logic:

```typescript
import { Injectable, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SendMessageDto, ChatResponseDto } from './dto/chat.dto';
import { OpenAIService } from './openai.service';

@Injectable()
export class ChatService {
  constructor(
    private prisma: PrismaService,
    private openaiService: OpenAIService,
  ) {}

  /**
   * Check if user can send a message (free tier limit)
   */
  async checkMessageLimit(userId: string): Promise<{
    canSend: boolean;
    remainingMessages: number;
    isPremium: boolean;
    resetAt: Date;
  }> {
    const FREE_TIER_DAILY_LIMIT = 5;

    // Get or create user
    let user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      // Create user if not exists
      user = await this.prisma.user.create({
        data: {
          id: userId,
          dailyMessageCount: 0,
          dailyMessageResetAt: new Date(),
        },
      });
    }

    // Premium users have unlimited messages
    if (user.isPremium) {
      return {
        canSend: true,
        remainingMessages: -1, // -1 means unlimited
        isPremium: true,
        resetAt: user.dailyMessageResetAt,
      };
    }

    // Check if we need to reset the counter (new day)
    const now = new Date();
    const resetAt = new Date(user.dailyMessageResetAt);
    
    if (now >= resetAt) {
      // Reset counter for new day
      const tomorrow = new Date(now);
      tomorrow.setDate(tomorrow.getDate() + 1);
      tomorrow.setHours(0, 0, 0, 0); // Midnight

      user = await this.prisma.user.update({
        where: { id: userId },
        data: {
          dailyMessageCount: 0,
          dailyMessageResetAt: tomorrow,
        },
      });
    }

    // Check if user has exceeded limit
    const remaining = FREE_TIER_DAILY_LIMIT - user.dailyMessageCount;
    const canSend = remaining > 0;

    return {
      canSend,
      remainingMessages: remaining,
      isPremium: false,
      resetAt: user.dailyMessageResetAt,
    };
  }

  /**
   * Increment user's daily message count
   */
  async incrementMessageCount(userId: string): Promise<void> {
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        dailyMessageCount: {
          increment: 1,
        },
      },
    });
  }

  /**
   * Main method to process user messages with ChatGPT
   */
  async processMessage(dto: SendMessageDto): Promise<ChatResponseDto> {
    const userId = dto.userId || 'anonymous';
    const { message, conversationId } = dto;

    // ⭐ Step 1: Check message limit
    const limitCheck = await this.checkMessageLimit(userId);
    
    if (!limitCheck.canSend) {
      throw new ForbiddenException({
        message: 'Daily message limit reached',
        code: 'MESSAGE_LIMIT_EXCEEDED',
        remainingMessages: 0,
        resetAt: limitCheck.resetAt,
        isPremium: limitCheck.isPremium,
      });
    }

    // Step 2: Get or create conversation
    let conversation;
    if (conversationId) {
      conversation = await this.prisma.conversation.findUnique({
        where: { id: conversationId },
      });
    }

    if (!conversation) {
      const title = message.substring(0, 50) + (message.length > 50 ? '...' : '');
      conversation = await this.prisma.conversation.create({
        data: {
          userId,
          title,
        },
      });
    }

    // Step 3: Save user message
    await this.prisma.message.create({
      data: {
        conversationId: conversation.id,
        sender: 'user',
        content: { text: message },
      },
    });

    // Step 4: Get AI response
    console.log('🤖 Asking ChatGPT:', message);
    const aiResponse = await this.openaiService.askAboutQuran(message);
    console.log('✅ ChatGPT response received');

    // Step 5: Fetch verses from database
    let verses = await this.fetchVersesFromDB(aiResponse.verses);
    console.log(`📚 Found ${verses.length} verses in database`);

    // Step 6: Fallback if no verses found
    let summary = aiResponse.summary;
    if (verses.length === 0) {
      console.log('⚠️ No verses found, showing sample verses');
      verses = await this.prisma.quranVerse.findMany({
        take: 2,
        skip: Math.floor(Math.random() * 6),
      });
      summary = `${summary}\n\n💡 Not: Belirtilen ayetler henüz veritabanımıza eklenmemiş. Yakın konuda örnek ayetler gösterilmektedir.`;
    }

    // Step 7: Create response
    const responseContent = {
      summary,
      verses: verses.map(v => ({
        surah: v.surah,
        ayah: v.ayah,
        arabic: v.text_ar,
        turkish: v.text_tr,
        surahName: v.surah_name || '',
      })),
    };

    // Step 8: Save assistant response
    await this.prisma.message.create({
      data: {
        conversationId: conversation.id,
        sender: 'assistant',
        content: responseContent,
      },
    });

    // ⭐ Step 9: Increment message count (only AFTER successful response)
    await this.incrementMessageCount(userId);

    // ⭐ Step 10: Get updated limit info
    const updatedLimit = await this.checkMessageLimit(userId);

    return {
      conversationId: conversation.id,
      response: responseContent,
      // ⭐ Include usage info in response
      usage: {
        remainingMessages: updatedLimit.remainingMessages,
        isPremium: updatedLimit.isPremium,
        resetAt: updatedLimit.resetAt.toISOString(),
      },
    };
  }

  // ... rest of existing methods ...
  
  private async fetchVersesFromDB(verses: any[]): Promise<any[]> {
    if (!verses || verses.length === 0) return [];

    const results = await Promise.all(
      verses.map(async (v) => {
        return this.prisma.quranVerse.findUnique({
          where: {
            surah_ayah: {
              surah: v.surah,
              ayah: v.ayah,
            },
          },
        });
      }),
    );

    return results.filter((v) => v !== null);
  }
}
```

### Update DTO to Include Usage Info

Update `backend/src/chat/dto/chat.dto.ts`:

```typescript
export class ChatResponseDto {
  conversationId: string;
  response: {
    summary: string;
    verses: any[];
  };
  
  // ⭐ NEW: Usage information
  usage?: {
    remainingMessages: number; // -1 = unlimited (premium)
    isPremium: boolean;
    resetAt: string; // ISO datetime
  };
}
```

---

## 📱 Step 3: Update Mobile App

### Update API Service to Handle Limit Errors

Update `mobile/lib/services/api_service.dart`:

```dart
class ChatResponse {
  final String conversationId;
  final AssistantMessageContent response;
  final ChatUsage? usage; // ⭐ NEW

  ChatResponse({
    required this.conversationId,
    required this.response,
    this.usage,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      conversationId: json['conversationId'] as String,
      response: AssistantMessageContent.fromJson(
        json['response'] as Map<String, dynamic>,
      ),
      usage: json['usage'] != null 
        ? ChatUsage.fromJson(json['usage'] as Map<String, dynamic>)
        : null,
    );
  }
}

// ⭐ NEW: Usage tracking model
class ChatUsage {
  final int remainingMessages; // -1 = unlimited
  final bool isPremium;
  final DateTime resetAt;

  ChatUsage({
    required this.remainingMessages,
    required this.isPremium,
    required this.resetAt,
  });

  factory ChatUsage.fromJson(Map<String, dynamic> json) {
    return ChatUsage(
      remainingMessages: json['remainingMessages'] as int,
      isPremium: json['isPremium'] as bool,
      resetAt: DateTime.parse(json['resetAt'] as String),
    );
  }
  
  bool get isUnlimited => remainingMessages == -1;
  
  String get displayText {
    if (isUnlimited) return 'Sınırsız';
    return '$remainingMessages mesaj kaldı';
  }
}

// ⭐ NEW: Custom exception for limit reached
class MessageLimitException implements Exception {
  final int remainingMessages;
  final DateTime resetAt;
  final bool isPremium;

  MessageLimitException({
    required this.remainingMessages,
    required this.resetAt,
    required this.isPremium,
  });
  
  String get resetTimeText {
    final now = DateTime.now();
    final difference = resetAt.difference(now);
    
    if (difference.inHours > 0) {
      return '${difference.inHours} saat sonra';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika sonra';
    } else {
      return 'Birkaç saniye sonra';
    }
  }

  @override
  String toString() => 'Günlük mesaj limitine ulaştınız';
}

class ApiService {
  // ... existing code ...
  
  Future<ChatResponse> sendMessage({
    required String message,
    String? conversationId,
  }) async {
    try {
      final userId = AuthService().userId ?? AuthService().deviceId ?? 'anonymous';
      
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/chat'),
        headers: _getHeaders(),
        body: jsonEncode({
          'message': message,
          if (conversationId != null) 'conversationId': conversationId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatResponse.fromJson(data);
      } 
      
      // ⭐ Handle limit exceeded (403 Forbidden)
      else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'MESSAGE_LIMIT_EXCEEDED') {
          throw MessageLimitException(
            remainingMessages: data['remainingMessages'] ?? 0,
            resetAt: DateTime.parse(data['resetAt']),
            isPremium: data['isPremium'] ?? false,
          );
        }
        throw ApiException('Access denied', 403);
      } 
      
      else {
        throw ApiException(
          'Failed to send message: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on MessageLimitException {
      rethrow; // Re-throw limit exception
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }
}
```

### Update Chat Provider to Track Usage

Update `mobile/lib/providers/chat_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/message.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<Message> _messages = [];
  String? _conversationId;
  bool _isLoading = false;
  String? _error;
  
  // ⭐ NEW: Usage tracking
  ChatUsage? _usage;
  bool _limitReached = false;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ChatUsage? get usage => _usage;
  bool get limitReached => _limitReached;
  
  // Helper getters
  bool get isPremium => _usage?.isPremium ?? false;
  String get remainingMessagesText => _usage?.displayText ?? '';
  
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_limitReached) return; // Don't send if limit reached

    // Add user message to UI immediately
    final userMessage = Message(
      id: DateTime.now().toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.sendMessage(
        message: text,
        conversationId: _conversationId,
      );

      _conversationId = response.conversationId;
      
      // ⭐ Update usage info
      _usage = response.usage;
      _limitReached = false;

      // Add AI response
      final aiMessage = Message(
        id: DateTime.now().toString(),
        text: response.response.summary,
        isUser: false,
        timestamp: DateTime.now(),
        verses: response.response.verses,
      );
      _messages.add(aiMessage);
      
    } on MessageLimitException catch (e) {
      // ⭐ Handle limit reached
      _limitReached = true;
      _error = 'Günlük ${e.remainingMessages == 0 ? "5" : ""} mesaj limitine ulaştınız. ${e.resetTimeText} yeniden deneyin.';
      
      // Show upgrade prompt
      // This will be handled in the UI
      
    } catch (e) {
      _error = 'Bir hata oluştu: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void clearMessages() {
    _messages.clear();
    _conversationId = null;
    _error = null;
    _limitReached = false;
    _usage = null;
    notifyListeners();
  }
}
```

---

## 🎨 Step 4: Update UI to Show Limits

### Add Usage Banner to Chat Screen

Update `mobile/lib/screens/chat_screen.dart`:

```dart
// Add this widget at the top of the chat messages area

Widget _buildUsageBanner(ChatProvider chatProvider) {
  if (chatProvider.usage == null) return const SizedBox.shrink();
  
  final usage = chatProvider.usage!;
  final isPremium = usage.isPremium;
  final remaining = usage.remainingMessages;
  
  // Don't show banner for premium users with unlimited
  if (isPremium && usage.isUnlimited) return const SizedBox.shrink();
  
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: remaining > 2
          ? LinearGradient(
              colors: [
                Colors.green.withOpacity(0.1),
                Colors.green.withOpacity(0.05),
              ],
            )
          : LinearGradient(
              colors: [
                Colors.orange.withOpacity(0.2),
                Colors.orange.withOpacity(0.1),
              ],
            ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: remaining > 2 
            ? Colors.green.withOpacity(0.3)
            : Colors.orange.withOpacity(0.4),
      ),
    ),
    child: Row(
      children: [
        Icon(
          remaining > 2 ? Icons.check_circle_outline : Icons.warning_amber_rounded,
          color: remaining > 2 ? Colors.green : Colors.orange,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            remaining == -1 
                ? '✨ Premium: Sınırsız mesaj'
                : remaining > 0
                    ? 'Bugün $remaining mesajınız kaldı'
                    : 'Günlük limit doldu',
            style: TextStyle(
              color: remaining > 2 ? Colors.green[800] : Colors.orange[900],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        if (remaining <= 2 && !isPremium)
          TextButton(
            onPressed: () {
              // Show paywall
              _showUpgradeDialog();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text(
              'Yükselt',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
      ],
    ),
  );
}

// Add limit reached overlay
Widget _buildLimitReachedOverlay() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Günlük Limit Doldu',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Ücretsiz kullanıcılar günde 5 mesaj gönderebilir.\nYarın tekrar deneyin veya Premium\'a yükseltin.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Kapat'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to paywall
                  _showPaywall();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '✨ Premium\'a Geç',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _showUpgradeDialog() {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: _buildLimitReachedOverlay(),
    ),
  );
}
```

---

## 🔐 Step 5: Sync with RevenueCat

### Update User Premium Status

Create `backend/src/user/user.controller.ts`:

```typescript
import { Controller, Post, Body } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Controller('user')
export class UserController {
  constructor(private prisma: PrismaService) {}

  /**
   * Update user premium status from RevenueCat webhook
   */
  @Post('update-premium')
  async updatePremiumStatus(
    @Body() body: { userId: string; isPremium: boolean },
  ) {
    const { userId, isPremium } = body;

    await this.prisma.user.upsert({
      where: { id: userId },
      update: { isPremium },
      create: {
        id: userId,
        isPremium,
        dailyMessageCount: 0,
        dailyMessageResetAt: new Date(),
      },
    });

    return { success: true };
  }
}
```

### Update Mobile App After Purchase

Update `mobile/lib/services/subscription_service.dart`:

```dart
// Add method to sync premium status with backend
Future<void> syncPremiumStatus() async {
  if (!_isInitialized) return;
  
  try {
    final userId = await AuthService().userId;
    if (userId == null) return;
    
    final customerInfo = await Purchases.getCustomerInfo();
    final isPremium = customerInfo.entitlements.active.containsKey(_entitlementId);
    
    // Sync with backend
    await ApiService().post('/user/update-premium', {
      'userId': userId,
      'isPremium': isPremium,
    });
    
    _isPremium = isPremium;
    notifyListeners(); // If using ChangeNotifier
    
  } catch (e) {
    debugPrint('Error syncing premium status: $e');
  }
}
```

Call this after successful purchase:

```dart
final result = await SubscriptionService().purchase(package);
if (result == PurchaseResultType.success) {
  await SubscriptionService().syncPremiumStatus();
}
```

---

## ✅ Testing Checklist

### Backend Testing
- [ ] Create test user, send 5 messages
- [ ] 6th message returns 403 error
- [ ] Error includes remaining count and reset time
- [ ] Premium user can send unlimited messages
- [ ] Counter resets at midnight

### Mobile App Testing
- [ ] Usage banner shows remaining messages
- [ ] Banner turns orange at 2 messages left
- [ ] Limit reached dialog appears
- [ ] Can't send messages when limit reached
- [ ] Premium users see "unlimited" badge
- [ ] After purchase, limits removed immediately

### Edge Cases
- [ ] Anonymous users get limits
- [ ] Logged-in users get limits
- [ ] Switching accounts updates limits
- [ ] Offline mode handles gracefully
- [ ] App restart persists limit state

---

## 📊 Analytics to Track

Add these events to track monetization:

```dart
// When limit warning shown (2 messages left)
analytics.logEvent('chat_limit_warning', {
  'remaining': 2,
  'is_premium': false,
});

// When limit reached
analytics.logEvent('chat_limit_reached', {
  'total_sent_today': 5,
  'conversion_shown': true,
});

// When upgrade button clicked
analytics.logEvent('upgrade_prompt_clicked', {
  'source': 'chat_limit',
});

// When user upgrades after seeing limit
analytics.logEvent('upgrade_from_limit', {
  'minutes_since_limit': 5,
});
```

---

## 💡 Pro Tips

### 1. **Soft Limits are Better**
- Show warning at 2 messages left
- Builds urgency without frustration
- Higher conversion rate

### 2. **Make Premium Worth It**
- Free: 5 messages/day
- Premium: Unlimited + faster responses
- Show comparison in paywall

### 3. **Good UX**
- Clear countdown ("3 messages left today")
- Friendly error messages
- Easy upgrade path (1 tap)

### 4. **Avoid Abuse**
- Track by device ID + IP
- Rate limit API endpoints (10 req/min)
- Ban suspicious users

---

## 🎯 Expected Conversion Rates

Based on industry data:

| Metric | Rate |
|--------|------|
| Users who hit limit | 40% |
| See upgrade prompt | 100% of those |
| Click "Upgrade" | 25% |
| Complete purchase | 40% of clicks |
| **Overall free → paid** | **~4-6%** |

With 1000 users:
- 400 hit limit
- 100 click upgrade
- 40-60 become paying customers
- **= $400-600/month recurring revenue**

---

## 🚀 Launch Checklist

- [ ] Database migration applied
- [ ] Backend code deployed
- [ ] Mobile app updated
- [ ] Tested on real device
- [ ] RevenueCat sync working
- [ ] Analytics tracking added
- [ ] Error messages user-friendly
- [ ] Paywall designed and integrated

---

**Implementation Time:** 2-3 hours  
**Complexity:** Medium  
**Impact:** High (critical for monetization)

Good luck! This is a standard pattern used by ChatGPT, Midjourney, and most AI apps. It works! 🚀

