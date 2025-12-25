import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking Quran reading progress locally
/// This will sync with backend in Phase 2 (User System)
class ReadingProgressService {
  static const String _progressKey = 'surah_reading_progress';
  static const String _lastReadKey = 'last_read_position';
  
  // Singleton instance
  static final ReadingProgressService _instance = ReadingProgressService._internal();
  factory ReadingProgressService() => _instance;
  ReadingProgressService._internal();
  
  // Cached progress data: {surahNumber: Set<verseNumbers>}
  Map<int, Set<int>> _readVerses = {};
  bool _isInitialized = false;
  
  // Surah verse counts (total verses per surah)
  static const Map<int, int> surahVerseCounts = {
    1: 7, 2: 286, 3: 200, 4: 176, 5: 120, 6: 165, 7: 206, 8: 75, 9: 129, 10: 109,
    11: 123, 12: 111, 13: 43, 14: 52, 15: 99, 16: 128, 17: 111, 18: 110, 19: 98, 20: 135,
    21: 112, 22: 78, 23: 118, 24: 64, 25: 77, 26: 227, 27: 93, 28: 88, 29: 69, 30: 60,
    31: 34, 32: 30, 33: 73, 34: 54, 35: 45, 36: 83, 37: 182, 38: 88, 39: 75, 40: 85,
    41: 54, 42: 53, 43: 89, 44: 59, 45: 37, 46: 35, 47: 38, 48: 29, 49: 18, 50: 45,
    51: 60, 52: 49, 53: 62, 54: 55, 55: 78, 56: 96, 57: 29, 58: 22, 59: 24, 60: 13,
    61: 14, 62: 11, 63: 11, 64: 18, 65: 12, 66: 12, 67: 30, 68: 52, 69: 52, 70: 44,
    71: 28, 72: 28, 73: 20, 74: 56, 75: 40, 76: 31, 77: 50, 78: 40, 79: 46, 80: 42,
    81: 29, 82: 19, 83: 36, 84: 25, 85: 22, 86: 17, 87: 19, 88: 26, 89: 30, 90: 20,
    91: 15, 92: 21, 93: 11, 94: 8, 95: 8, 96: 19, 97: 5, 98: 8, 99: 8, 100: 11,
    101: 11, 102: 8, 103: 3, 104: 9, 105: 5, 106: 4, 107: 7, 108: 3, 109: 6, 110: 3,
    111: 5, 112: 4, 113: 5, 114: 6,
  };
  
  /// Initialize the service (call on app start)
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString(_progressKey);
      
      if (progressJson != null) {
        final Map<String, dynamic> decoded = json.decode(progressJson);
        _readVerses = decoded.map((key, value) => MapEntry(
          int.parse(key),
          Set<int>.from((value as List).map((e) => e as int)),
        ));
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to load reading progress: $e');
      _readVerses = {};
      _isInitialized = true;
    }
  }
  
  /// Save progress to local storage
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_readVerses.map(
        (key, value) => MapEntry(key.toString(), value.toList()),
      ));
      await prefs.setString(_progressKey, encoded);
    } catch (e) {
      debugPrint('Failed to save reading progress: $e');
    }
  }
  
  /// Mark a verse as read
  Future<void> markVerseRead(int surahNumber, int verseNumber) async {
    await init();
    _readVerses.putIfAbsent(surahNumber, () => {});
    _readVerses[surahNumber]!.add(verseNumber);
    await _saveProgress();
    await _saveLastRead(surahNumber, verseNumber);
  }
  
  /// Mark multiple verses as read (e.g., when scrolling through a surah)
  Future<void> markVersesRead(int surahNumber, List<int> verseNumbers) async {
    await init();
    _readVerses.putIfAbsent(surahNumber, () => {});
    _readVerses[surahNumber]!.addAll(verseNumbers);
    await _saveProgress();
    if (verseNumbers.isNotEmpty) {
      await _saveLastRead(surahNumber, verseNumbers.last);
    }
  }
  
  /// Get progress percentage for a surah (0.0 to 1.0)
  double getSurahProgress(int surahNumber) {
    if (!_isInitialized) return 0.0;
    
    final totalVerses = surahVerseCounts[surahNumber] ?? 0;
    if (totalVerses == 0) return 0.0;
    
    final readCount = _readVerses[surahNumber]?.length ?? 0;
    return (readCount / totalVerses).clamp(0.0, 1.0);
  }
  
  /// Check if a surah is completed (100%)
  bool isSurahCompleted(int surahNumber) {
    return getSurahProgress(surahNumber) >= 1.0;
  }
  
  /// Get number of verses read in a surah
  int getVersesReadCount(int surahNumber) {
    if (!_isInitialized) return 0;
    return _readVerses[surahNumber]?.length ?? 0;
  }
  
  /// Get total verses in a surah
  int getTotalVerses(int surahNumber) {
    return surahVerseCounts[surahNumber] ?? 0;
  }
  
  /// Check if a specific verse has been read
  bool isVerseRead(int surahNumber, int verseNumber) {
    if (!_isInitialized) return false;
    return _readVerses[surahNumber]?.contains(verseNumber) ?? false;
  }
  
  /// Save last read position
  Future<void> _saveLastRead(int surahNumber, int verseNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastReadKey, '$surahNumber:$verseNumber');
    } catch (e) {
      debugPrint('Failed to save last read position: $e');
    }
  }
  
  /// Get last read position
  Future<Map<String, int>?> getLastReadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRead = prefs.getString(_lastReadKey);
      if (lastRead != null) {
        final parts = lastRead.split(':');
        return {
          'surah': int.parse(parts[0]),
          'verse': int.parse(parts[1]),
        };
      }
    } catch (e) {
      debugPrint('Failed to get last read position: $e');
    }
    return null;
  }
  
  /// Get overall Quran progress (total verses read / 6236)
  double getOverallProgress() {
    if (!_isInitialized) return 0.0;
    int totalRead = 0;
    for (final verses in _readVerses.values) {
      totalRead += verses.length;
    }
    return (totalRead / 6236).clamp(0.0, 1.0);
  }
  
  /// Get count of completed surahs
  int getCompletedSurahsCount() {
    int count = 0;
    for (int i = 1; i <= 114; i++) {
      if (isSurahCompleted(i)) count++;
    }
    return count;
  }
  
  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    _readVerses = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    await prefs.remove(_lastReadKey);
  }
}





