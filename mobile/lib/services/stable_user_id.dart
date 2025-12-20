import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// =============================================================================
// STABLE USER ID SERVICE
// =============================================================================
//
// Provides a stable, persistent appUserId for RevenueCat configuration.
//
// CRITICAL: The appUserId MUST:
// - Be generated once on first launch
// - Persist across app restarts
// - NEVER change during the app's lifetime
// - Survive app updates and reinstalls (via SharedPreferences)
//
// This ID is used as the RevenueCat appUserID to ensure:
// - Consistent entitlement tracking
// - No "PRO gidip geliyor" issues
// - Proper subscription restoration
//
// =============================================================================

class StableUserIdService {
  // ===========================================================================
  // SINGLETON
  // ===========================================================================
  
  static final StableUserIdService _instance = StableUserIdService._internal();
  
  /// Singleton instance
  static StableUserIdService get I => _instance;
  
  StableUserIdService._internal();

  // ===========================================================================
  // CONFIGURATION
  // ===========================================================================
  
  /// Key used in SharedPreferences
  /// This key should NEVER change - changing it would generate new IDs
  static const String _prefKey = 'rc_app_user_id';

  // ===========================================================================
  // STATE
  // ===========================================================================
  
  String? _userId;
  bool _isInitialized = false;

  /// Get the stable user ID
  /// Returns null if not initialized
  String? get userId => _userId;
  
  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================
  
  /// Initialize the stable user ID
  /// 
  /// Call this before RevenueCat configuration.
  /// Generates a new UUID on first launch, returns existing on subsequent launches.
  Future<String> initialize() async {
    if (_isInitialized && _userId != null) {
      debugPrint('StableUserIdService: Already initialized with ID: $_userId');
      return _userId!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to read existing ID
      _userId = prefs.getString(_prefKey);
      
      if (_userId != null) {
        // Existing user - ID was persisted
        debugPrint('StableUserIdService: Loaded existing ID: $_userId');
      } else {
        // First launch - generate new ID
        _userId = const Uuid().v4();
        await prefs.setString(_prefKey, _userId!);
        debugPrint('StableUserIdService: Generated new ID: $_userId');
      }
      
      _isInitialized = true;
      return _userId!;
      
    } catch (e) {
      debugPrint('StableUserIdService: Error during initialization: $e');
      
      // Fallback: generate in-memory ID (not ideal but better than nothing)
      // This should rarely happen as SharedPreferences is very reliable
      if (_userId == null) {
        _userId = const Uuid().v4();
        debugPrint('StableUserIdService: Using fallback in-memory ID: $_userId');
      }
      
      _isInitialized = true;
      return _userId!;
    }
  }

  /// Get the user ID, initializing if needed
  /// 
  /// Prefer calling initialize() explicitly at app startup,
  /// but this method is safe to call anywhere.
  Future<String> getUserId() async {
    if (_userId != null) return _userId!;
    return await initialize();
  }

  // ===========================================================================
  // DEBUG
  // ===========================================================================
  
  /// Reset the user ID (for testing only)
  /// 
  /// WARNING: This will create a new user in RevenueCat.
  /// Only use this for testing purposes.
  @visibleForTesting
  Future<void> resetForTesting() async {
    debugPrint('⚠️ StableUserIdService: Resetting user ID (TESTING ONLY)');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKey);
      _userId = null;
      _isInitialized = false;
    } catch (e) {
      debugPrint('StableUserIdService: Error resetting: $e');
    }
  }
}

