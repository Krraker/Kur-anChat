import 'package:flutter/foundation.dart';
import '../services/daily_content_service.dart';

/// Provider for daily content state management
class DailyContentProvider extends ChangeNotifier {
  final DailyContentService _service = DailyContentService();

  DailyContentResponse? _dailyContent;
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetched;

  // Getters
  DailyContentResponse? get dailyContent => _dailyContent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _dailyContent != null;

  // Convenience getters
  VerseData? get verseOfDay => _dailyContent?.verseOfDay;
  TafsirData? get tafsir => _dailyContent?.tafsir;
  PrayerData? get prayer => _dailyContent?.prayer;
  DateInfo? get dateInfo => _dailyContent?.date;

  /// Fetch daily content from API
  Future<void> fetchDailyContent({bool forceRefresh = false}) async {
    // Check if we already have today's content
    if (!forceRefresh && _dailyContent != null && _lastFetched != null) {
      final now = DateTime.now();
      final isSameDay = _lastFetched!.year == now.year &&
          _lastFetched!.month == now.month &&
          _lastFetched!.day == now.day;
      if (isSameDay) return; // Already have today's content
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dailyContent = await _service.getDailyContent();
      _lastFetched = DateTime.now();
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Use fallback content
      _dailyContent = DailyContentResponse.fallback();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a random verse for sharing
  Future<VerseData> getRandomVerse() async {
    try {
      return await _service.getRandomVerse();
    } catch (e) {
      return VerseData.fallback();
    }
  }

  /// Get a random prayer
  Future<PrayerData> getRandomPrayer() async {
    try {
      return await _service.getRandomPrayer();
    } catch (e) {
      return PrayerData.fallback();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}





