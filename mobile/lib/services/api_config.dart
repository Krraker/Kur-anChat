import 'dart:io';

/// API Configuration for the app
class ApiConfig {
  // Singleton instance
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  /// Get the appropriate base URL based on platform
  String get baseUrl {
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

  /// Production URL (update when deploying)
  static const String productionUrl = 'https://your-api-domain.com/api';

  /// Check if we're in production mode
  static const bool isProduction = false;

  /// Get the active URL
  String get activeUrl => isProduction ? productionUrl : baseUrl;

  /// Timeout duration for API calls
  Duration get timeout => const Duration(seconds: 10);

  /// Headers for API requests
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
