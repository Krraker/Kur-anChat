import 'package:flutter/foundation.dart';
import '../services/user_service.dart';

/// Provider for user state management
class UserProvider extends ChangeNotifier {
  final UserService _service = UserService();

  UserProgress? _progress;
  bool _isInitialized = false;
  bool _isLoading = false;

  // Getters
  UserProgress get progress => _progress ?? UserProgress.initial();
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String get deviceId => _service.deviceId;

  // Convenience getters
  int get level => progress.level;
  int get xp => progress.xp;
  int get streak => progress.streak;
  int get totalVersesRead => progress.totalVersesRead;
  String get title => progress.title;
  double get levelProgress => progress.levelProgress;

  /// Initialize user service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _service.initialize();
      await _service.loadLocalProgress();
      _progress = await _service.getProgress();
      await _service.updateStreak();
      _progress = await _service.getProgress();
      _isInitialized = true;
    } catch (e) {
      print('⚠️ User initialization error: $e');
      _progress = UserProgress.initial();
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark a verse as read
  Future<void> markVerseAsRead(int surah, int ayah) async {
    await _service.markVerseAsRead(surah, ayah);
    _progress = await _service.getProgress();
    await _service.addXp(5); // 5 XP per verse read
    _progress = await _service.getProgress();
    notifyListeners();
  }

  /// Add XP for various actions
  Future<void> addXp(int amount) async {
    await _service.addXp(amount);
    _progress = await _service.getProgress();
    notifyListeners();
  }

  /// Refresh progress from server
  Future<void> refreshProgress() async {
    _progress = await _service.getProgress();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
