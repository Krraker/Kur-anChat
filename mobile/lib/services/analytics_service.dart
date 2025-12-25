import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking app analytics with Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  bool _isInitialized = false;

  /// Initialize Firebase Analytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _isInitialized = true;
      debugPrint('✅ AnalyticsService: Initialized successfully');
    } catch (e) {
      debugPrint('❌ AnalyticsService: Initialization error: $e');
    }
  }

  /// Get the analytics instance (for FirebaseAnalyticsObserver in routes)
  FirebaseAnalytics? get analytics => _analytics;

  // ==========================================================================
  // CHAT LIMIT EVENTS
  // ==========================================================================

  /// Log when user is warned about approaching chat limit
  Future<void> logChatLimitWarning({required int remainingMessages}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'chat_limit_warning',
        parameters: {
          'remaining_messages': remainingMessages,
          'is_premium': false,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Chat limit warning (remaining: $remainingMessages)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when user hits the 3-message limit
  Future<void> logChatLimitReached({required int messagesSent}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'chat_limit_reached',
        parameters: {
          'messages_sent': messagesSent,
          'is_premium': false,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Chat limit reached (sent: $messagesSent)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when upgrade prompt is shown
  Future<void> logUpgradePromptShown({required String source}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'upgrade_prompt_shown',
        parameters: {
          'source': source, // 'chat_limit', 'banner', 'settings', etc.
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Upgrade prompt shown (source: $source)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when user clicks upgrade button
  Future<void> logUpgradeButtonClicked({required String source}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'upgrade_button_clicked',
        parameters: {
          'source': source,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Upgrade button clicked (source: $source)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ==========================================================================
  // PURCHASE EVENTS
  // ==========================================================================

  /// Log when user successfully purchases premium
  Future<void> logPremiumPurchase({
    required String plan,
    required double price,
    String? fromSource,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'purchase',
        parameters: {
          'value': price,
          'currency': 'USD',
          'transaction_id': DateTime.now().millisecondsSinceEpoch.toString(),
          'item_name': plan, // 'weekly', 'monthly', 'annual'
          'from_source': fromSource ?? 'unknown', // Where they came from
        },
      );
      debugPrint('📊 Analytics: Premium purchased ($plan - \$$price)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when purchase is cancelled
  Future<void> logPurchaseCancelled({required String plan}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'purchase_cancelled',
        parameters: {
          'plan': plan,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Purchase cancelled ($plan)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ==========================================================================
  // READING EVENTS
  // ==========================================================================

  /// Log when user reads a verse
  Future<void> logVerseRead({
    required int surah,
    required int ayah,
    String? surahName,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'verse_read',
        parameters: {
          'surah': surah,
          'ayah': ayah,
          'surah_name': surahName ?? 'Unknown',
        },
      );
      debugPrint('📊 Analytics: Verse read ($surah:$ayah)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when user completes reading a surah
  Future<void> logSurahCompleted({
    required int surah,
    String? surahName,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'surah_completed',
        parameters: {
          'surah': surah,
          'surah_name': surahName ?? 'Unknown',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Surah completed ($surah)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ==========================================================================
  // CHAT EVENTS
  // ==========================================================================

  /// Log when user sends a chat message
  Future<void> logChatMessageSent({
    required int messageLength,
    bool isPremium = false,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'chat_message_sent',
        parameters: {
          'message_length': messageLength,
          'is_premium': isPremium,
        },
      );
      debugPrint('📊 Analytics: Chat message sent (length: $messageLength)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when AI responds to chat
  Future<void> logChatResponseReceived({
    required int responseLength,
    required int versesCount,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'chat_response_received',
        parameters: {
          'response_length': responseLength,
          'verses_count': versesCount,
        },
      );
      debugPrint('📊 Analytics: Chat response received');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ==========================================================================
  // GAMIFICATION EVENTS
  // ==========================================================================

  /// Log when user levels up
  Future<void> logLevelUp({required int newLevel, required int xp}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'level_up',
        parameters: {
          'level': newLevel,
          'xp': xp,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Level up (level: $newLevel)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when user updates streak
  Future<void> logStreakUpdated({required int streak, bool isBroken = false}) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: isBroken ? 'streak_broken' : 'streak_updated',
        parameters: {
          'streak': streak,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Streak ${isBroken ? "broken" : "updated"} ($streak)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log when user unlocks an achievement
  Future<void> logAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: 'achievement_unlocked',
        parameters: {
          'achievement_id': achievementId,
          'achievement_name': achievementName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Achievement unlocked ($achievementName)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ==========================================================================
  // APP USAGE EVENTS
  // ==========================================================================

  /// Log when user opens the app
  Future<void> logAppOpen() async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(name: 'app_open');
      debugPrint('📊 Analytics: App opened');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log screen views (use with navigator observer)
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      debugPrint('📊 Analytics: Screen view ($screenName)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ==========================================================================
  // USER PROPERTIES
  // ==========================================================================

  /// Set user property for premium status
  Future<void> setUserPremiumStatus(bool isPremium) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(
        name: 'is_premium',
        value: isPremium.toString(),
      );
      debugPrint('📊 Analytics: User premium status set ($isPremium)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Set user property for language
  Future<void> setUserLanguage(String language) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(
        name: 'language',
        value: language,
      );
      debugPrint('📊 Analytics: User language set ($language)');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    if (!_isInitialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
      debugPrint('📊 Analytics: User ID set');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }
}

