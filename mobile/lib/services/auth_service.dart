import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// Service to handle device-based authentication
/// For MVP, we use anonymous auth based on device ID
class AuthService {
  static const String _deviceIdKey = 'device_id';
  static const String _userIdKey = 'user_id';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _deviceId;
  String? _userId;
  bool _isInitialized = false;
  bool _onboardingComplete = false;

  /// Unique device identifier (generated on first launch)
  String? get deviceId => _deviceId;

  /// User ID from backend (set after registration)
  String? get userId => _userId;

  /// Whether the user has completed onboarding
  bool get onboardingComplete => _onboardingComplete;

  /// Whether auth service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize auth service - call this on app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Read existing values
      _deviceId = await _storage.read(key: _deviceIdKey);
      _userId = await _storage.read(key: _userIdKey);
      final onboardingStr = await _storage.read(key: _onboardingCompleteKey);
      _onboardingComplete = onboardingStr == 'true';

      // Generate device ID if first launch
      if (_deviceId == null) {
        _deviceId = const Uuid().v4();
        await _storage.write(key: _deviceIdKey, value: _deviceId);
        debugPrint('AuthService: Generated new device ID: $_deviceId');
      } else {
        debugPrint('AuthService: Loaded device ID: $_deviceId');
      }

      _isInitialized = true;
      debugPrint('AuthService: Initialized successfully');
    } catch (e) {
      debugPrint('AuthService: Initialization error: $e');
      // Fallback: generate a device ID in memory
      _deviceId ??= const Uuid().v4();
      _isInitialized = true;
    }
  }

  /// Set user ID after backend creates/returns user
  Future<void> setUserId(String userId) async {
    _userId = userId;
    try {
      await _storage.write(key: _userIdKey, value: userId);
      debugPrint('AuthService: User ID saved: $userId');
    } catch (e) {
      debugPrint('AuthService: Error saving user ID: $e');
    }
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete(bool complete) async {
    _onboardingComplete = complete;
    try {
      await _storage.write(key: _onboardingCompleteKey, value: complete.toString());
    } catch (e) {
      debugPrint('AuthService: Error saving onboarding status: $e');
    }
  }

  /// Get auth headers for API requests
  Map<String, String> getAuthHeaders() {
    final headers = <String, String>{};
    
    if (_deviceId != null) {
      headers['X-Device-ID'] = _deviceId!;
    }
    if (_userId != null) {
      headers['X-User-ID'] = _userId!;
    }
    
    return headers;
  }

  /// Check if user is authenticated (has device ID)
  bool get isAuthenticated => _deviceId != null;

  /// Check if user is registered with backend (has user ID)
  bool get isRegistered => _userId != null;

  /// Clear all auth data (for logout/reset)
  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _deviceIdKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _onboardingCompleteKey);
      _deviceId = null;
      _userId = null;
      _onboardingComplete = false;
      debugPrint('AuthService: Auth data cleared');
    } catch (e) {
      debugPrint('AuthService: Error clearing auth: $e');
    }
  }

  /// Reset for new device ID (useful for testing)
  Future<void> resetDeviceId() async {
    await clearAuth();
    _deviceId = const Uuid().v4();
    await _storage.write(key: _deviceIdKey, value: _deviceId);
    debugPrint('AuthService: Reset with new device ID: $_deviceId');
  }
}




