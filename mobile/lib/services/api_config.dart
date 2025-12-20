import 'dart:io';
import 'package:flutter/foundation.dart';

/// API Configuration for the app
class ApiConfig {
  // Singleton instance
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  /// Development URLs
  static String get _devBaseUrl {
    // For iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost:3001/api';
    }
    // For Android Emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3001/api';
    }
    // Default fallback
    return 'http://localhost:3001/api';
  }

  /// Production URL - UPDATE THIS with your Railway/Render URL
  static const String _prodBaseUrl = 'https://kuranchat-backend.up.railway.app/api';

  /// Check if we're in production mode
  /// In release builds, this will be true
  static bool get isProduction {
    return kReleaseMode;
  }

  /// Get the active base URL
  static String get baseUrl {
    return isProduction ? _prodBaseUrl : _devBaseUrl;
  }

  /// Instance method for backwards compatibility
  String get activeUrl => baseUrl;

  /// Timeout duration for API calls
  Duration get timeout => const Duration(seconds: 15);

  /// Default headers for API requests
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
