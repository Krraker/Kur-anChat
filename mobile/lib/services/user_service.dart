import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'api_config.dart';

/// User service for authentication and progress tracking
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiConfig _config = ApiConfig();
  final http.Client _client = http.Client();
  
  String? _deviceId;
  String? _userId;
  UserProgress? _cachedProgress;

  /// Initialize user (get or create device ID)
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString('device_id');
    
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString('device_id', _deviceId!);
    }
    
    // Try to sync with backend
    await _syncWithBackend();
  }

  /// Get current device ID
  String get deviceId => _deviceId ?? '';

  /// Get current user ID
  String? get userId => _userId;

  /// Sync device with backend and get/create user
  Future<void> _syncWithBackend() async {
    try {
      final response = await _client.post(
        Uri.parse('${_config.activeUrl}/user/register'),
        headers: _config.headers,
        body: jsonEncode({'deviceId': _deviceId}),
      ).timeout(_config.timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _userId = data['id'];
        if (data['progress'] != null) {
          _cachedProgress = UserProgress.fromJson(data['progress']);
        }
      }
    } catch (e) {
      // Offline mode - continue without sync
      print('⚠️ Could not sync with backend: $e');
    }
  }

  /// Get user progress
  Future<UserProgress> getProgress() async {
    if (_cachedProgress != null) return _cachedProgress!;

    try {
      final response = await _client.get(
        Uri.parse('${_config.activeUrl}/user/progress'),
        headers: {
          ..._config.headers,
          'X-Device-Id': _deviceId ?? '',
        },
      ).timeout(_config.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedProgress = UserProgress.fromJson(data);
        return _cachedProgress!;
      }
    } catch (e) {
      print('⚠️ Could not fetch progress: $e');
    }

    // Return default progress if offline
    return UserProgress.initial();
  }

  /// Update reading progress
  Future<void> markVerseAsRead(int surah, int ayah) async {
    // Update local cache
    _cachedProgress = _cachedProgress?.copyWith(
      lastReadSurah: surah,
      lastReadAyah: ayah,
      totalVersesRead: (_cachedProgress?.totalVersesRead ?? 0) + 1,
    ) ?? UserProgress.initial();

    // Save locally
    await _saveProgressLocally();

    // Sync with backend
    try {
      await _client.post(
        Uri.parse('${_config.activeUrl}/user/progress/verse-read'),
        headers: {
          ..._config.headers,
          'X-Device-Id': _deviceId ?? '',
        },
        body: jsonEncode({'surah': surah, 'ayah': ayah}),
      ).timeout(_config.timeout);
    } catch (e) {
      print('⚠️ Could not sync verse read: $e');
    }
  }

  /// Update streak
  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString('last_active_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastActiveStr == today) return; // Already active today

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayStr = yesterday.toIso8601String().split('T')[0];

    int newStreak;
    if (lastActiveStr == yesterdayStr) {
      // Continue streak
      newStreak = (_cachedProgress?.streak ?? 0) + 1;
    } else {
      // Reset streak
      newStreak = 1;
    }

    _cachedProgress = _cachedProgress?.copyWith(streak: newStreak) ?? 
        UserProgress.initial().copyWith(streak: newStreak);

    await prefs.setString('last_active_date', today);
    await _saveProgressLocally();

    // Sync with backend
    try {
      await _client.post(
        Uri.parse('${_config.activeUrl}/user/progress/update-streak'),
        headers: {
          ..._config.headers,
          'X-Device-Id': _deviceId ?? '',
        },
      ).timeout(_config.timeout);
    } catch (e) {
      print('⚠️ Could not sync streak: $e');
    }
  }

  /// Add XP
  Future<void> addXp(int amount) async {
    final currentXp = _cachedProgress?.xp ?? 0;
    final currentLevel = _cachedProgress?.level ?? 1;
    
    int newXp = currentXp + amount;
    int newLevel = currentLevel;
    
    // Level up calculation (100 XP per level)
    while (newXp >= 100) {
      newXp -= 100;
      newLevel++;
    }

    _cachedProgress = _cachedProgress?.copyWith(xp: newXp, level: newLevel) ?? 
        UserProgress.initial().copyWith(xp: newXp, level: newLevel);

    await _saveProgressLocally();
  }

  /// Save progress locally
  Future<void> _saveProgressLocally() async {
    if (_cachedProgress == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_progress', jsonEncode(_cachedProgress!.toJson()));
  }

  /// Load progress from local storage
  Future<void> loadLocalProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressStr = prefs.getString('user_progress');
    if (progressStr != null) {
      _cachedProgress = UserProgress.fromJson(jsonDecode(progressStr));
    }
  }

  void dispose() {
    _client.close();
  }
}

/// User progress model
class UserProgress {
  final int lastReadSurah;
  final int lastReadAyah;
  final int level;
  final int xp;
  final int streak;
  final int totalVersesRead;
  final int totalTimeSpent;
  final List<int> completedSurahs;

  UserProgress({
    required this.lastReadSurah,
    required this.lastReadAyah,
    required this.level,
    required this.xp,
    required this.streak,
    required this.totalVersesRead,
    required this.totalTimeSpent,
    required this.completedSurahs,
  });

  factory UserProgress.initial() {
    return UserProgress(
      lastReadSurah: 1,
      lastReadAyah: 1,
      level: 1,
      xp: 0,
      streak: 0,
      totalVersesRead: 0,
      totalTimeSpent: 0,
      completedSurahs: [],
    );
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      lastReadSurah: json['lastReadSurah'] ?? 1,
      lastReadAyah: json['lastReadAyah'] ?? 1,
      level: json['level'] ?? 1,
      xp: json['xp'] ?? 0,
      streak: json['streak'] ?? 0,
      totalVersesRead: json['totalVersesRead'] ?? 0,
      totalTimeSpent: json['totalTimeSpent'] ?? 0,
      completedSurahs: List<int>.from(json['completedSurahs'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastReadSurah': lastReadSurah,
      'lastReadAyah': lastReadAyah,
      'level': level,
      'xp': xp,
      'streak': streak,
      'totalVersesRead': totalVersesRead,
      'totalTimeSpent': totalTimeSpent,
      'completedSurahs': completedSurahs,
    };
  }

  UserProgress copyWith({
    int? lastReadSurah,
    int? lastReadAyah,
    int? level,
    int? xp,
    int? streak,
    int? totalVersesRead,
    int? totalTimeSpent,
    List<int>? completedSurahs,
  }) {
    return UserProgress(
      lastReadSurah: lastReadSurah ?? this.lastReadSurah,
      lastReadAyah: lastReadAyah ?? this.lastReadAyah,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      totalVersesRead: totalVersesRead ?? this.totalVersesRead,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      completedSurahs: completedSurahs ?? this.completedSurahs,
    );
  }

  /// Calculate progress percentage to next level
  double get levelProgress => xp / 100.0;

  /// Get title based on level
  String get title {
    if (level < 5) return 'Mübtedi';
    if (level < 10) return 'Talebe';
    if (level < 20) return 'Hafız Adayı';
    if (level < 30) return 'Hafız';
    if (level < 50) return 'Alim';
    return 'Müfessir';
  }
}


