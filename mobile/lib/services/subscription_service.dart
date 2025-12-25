import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'auth_service.dart';
import 'api_service.dart';

/// Result type for purchase operations
enum PurchaseResultType {
  success,
  cancelled,
  failed,
}

/// Service to handle in-app purchases and subscriptions via RevenueCat
class SubscriptionService {
  // TODO: Replace with your actual RevenueCat API keys from https://app.revenuecat.com
  static const String _apiKeyIOS = 'YOUR_REVENUECAT_IOS_API_KEY';
  static const String _apiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_API_KEY';

  // Entitlement ID configured in RevenueCat dashboard
  static const String _entitlementId = 'premium';

  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isInitialized = false;
  bool _isPremium = false;
  CustomerInfo? _customerInfo;
  List<Package> _packages = [];

  /// Whether the user has an active premium subscription
  bool get isPremium => _isPremium;

  /// Current customer info from RevenueCat
  CustomerInfo? get customerInfo => _customerInfo;

  /// Available subscription packages (cached after loadOfferings)
  List<Package> get packages => _packages;

  /// Last error message
  String? _error;
  String? get error => _error;

  /// Get weekly package
  Package? get weeklyPackage => _packages.cast<Package?>().firstWhere(
    (p) => p?.packageType == PackageType.weekly,
    orElse: () => null,
  );

  /// Get monthly package
  Package? get monthlyPackage => _packages.cast<Package?>().firstWhere(
    (p) => p?.packageType == PackageType.monthly,
    orElse: () => null,
  );

  /// Get yearly package
  Package? get yearlyPackage => _packages.cast<Package?>().firstWhere(
    (p) => p?.packageType == PackageType.annual,
    orElse: () => null,
  );

  /// Calculate yearly savings percentage compared to monthly
  int? get yearlySavingsPercent {
    final monthly = monthlyPackage;
    final yearly = yearlyPackage;
    if (monthly == null || yearly == null) return null;
    
    final monthlyAnnual = monthly.storeProduct.price * 12;
    final yearlyPrice = yearly.storeProduct.price;
    
    if (monthlyAnnual <= 0) return null;
    final savings = ((monthlyAnnual - yearlyPrice) / monthlyAnnual * 100).round();
    return savings > 0 ? savings : null;
  }

  /// Initialize RevenueCat SDK - call this on app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

      PurchasesConfiguration configuration;
      if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKeyIOS);
      } else if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKeyAndroid);
      } else {
        debugPrint('SubscriptionService: Unsupported platform');
        return;
      }

      await Purchases.configure(configuration);
      _isInitialized = true;

      // Check initial subscription status
      await checkSubscriptionStatus();

      // Listen for subscription changes
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updatePremiumStatus(customerInfo);
      });

      debugPrint('SubscriptionService: Initialized successfully');
    } catch (e) {
      debugPrint('SubscriptionService: Initialization error: $e');
    }
  }

  /// Check current subscription status
  Future<void> checkSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
    } catch (e) {
      debugPrint('SubscriptionService: Error checking subscription: $e');
    }
  }

  /// Update premium status based on customer info
  void _updatePremiumStatus(CustomerInfo customerInfo) {
    _customerInfo = customerInfo;
    _isPremium = customerInfo.entitlements.active.containsKey(_entitlementId);
    debugPrint('SubscriptionService: Premium status: $_isPremium');
  }

  /// Get available subscription packages
  Future<List<Package>> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint('SubscriptionService: Error getting offerings: $e');
    }
    return [];
  }

  /// Load offerings and cache them in [packages]
  Future<void> loadOfferings() async {
    _packages = await getOfferings();
    debugPrint('SubscriptionService: Loaded ${_packages.length} packages');
  }

  /// Purchase a package with result type
  Future<PurchaseResultType> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _updatePremiumStatus(result.customerInfo);
      return _isPremium ? PurchaseResultType.success : PurchaseResultType.failed;
    } on PurchasesErrorCode catch (e) {
      debugPrint('SubscriptionService: Purchase error code: $e');
      // Check if user cancelled
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResultType.cancelled;
      }
      return PurchaseResultType.failed;
    } catch (e) {
      debugPrint('SubscriptionService: Purchase error: $e');
      // Check for cancellation in error message
      if (e.toString().contains('cancelled') || e.toString().contains('canceled')) {
        return PurchaseResultType.cancelled;
      }
      return PurchaseResultType.failed;
    }
  }

  /// Restore purchases and return success status
  Future<bool> restore() async {
    return await restorePurchases();
  }

  /// Purchase a subscription package
  /// Returns true if purchase was successful
  Future<bool> purchasePackage(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      _updatePremiumStatus(result.customerInfo);
      return _isPremium;
    } on PurchasesErrorCode catch (e) {
      debugPrint('SubscriptionService: Purchase error: $e');
      return false;
    } catch (e) {
      debugPrint('SubscriptionService: Purchase error: $e');
      return false;
    }
  }

  /// Restore previous purchases
  /// Returns true if restoration found an active subscription
  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatus(customerInfo);
      return _isPremium;
    } catch (e) {
      debugPrint('SubscriptionService: Restore error: $e');
      return false;
    }
  }

  /// Link to user ID for cross-device subscription management
  Future<void> setUserId(String userId) async {
    if (!_isInitialized) return;
    
    try {
      await Purchases.logIn(userId);
      debugPrint('SubscriptionService: User ID set: $userId');
    } catch (e) {
      debugPrint('SubscriptionService: Error setting user ID: $e');
    }
  }

  /// Logout current user (for anonymous users or account switching)
  Future<void> logout() async {
    if (!_isInitialized) return;
    
    try {
      await Purchases.logOut();
      _isPremium = false;
      _customerInfo = null;
    } catch (e) {
      debugPrint('SubscriptionService: Logout error: $e');
    }
  }

  /// Get price string for a package (formatted for display)
  String getPriceString(Package package) {
    return package.storeProduct.priceString;
  }

  /// Get subscription period description
  String getPeriodString(Package package) {
    switch (package.packageType) {
      case PackageType.weekly:
        return 'Haftalık';
      case PackageType.monthly:
        return 'Aylık';
      case PackageType.annual:
        return 'Yıllık';
      case PackageType.lifetime:
        return 'Ömür Boyu';
      case PackageType.threeMonth:
        return '3 Aylık';
      case PackageType.sixMonth:
        return '6 Aylık';
      default:
        return '';
    }
  }

  /// ⭐ Sync premium status with backend after purchase
  Future<void> syncPremiumStatus() async {
    if (!_isInitialized) {
      debugPrint('SubscriptionService: Not initialized, cannot sync');
      return;
    }

    try {
      final userId = await AuthService().userId;
      if (userId == null) {
        debugPrint('SubscriptionService: No user ID, cannot sync');
        return;
      }

      // Get current subscription status from RevenueCat
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.containsKey(_entitlementId);

      debugPrint('SubscriptionService: Syncing premium status: $isPremium for user: $userId');

      // Sync with backend
      final apiService = ApiService();
      await apiService.post('/user/update-premium', {
        'userId': userId,
        'isPremium': isPremium,
      });

      _isPremium = isPremium;
      _customerInfo = customerInfo;

      debugPrint('SubscriptionService: ✅ Premium status synced successfully');
    } catch (e) {
      debugPrint('SubscriptionService: ❌ Error syncing premium status: $e');
      // Don't throw - this is not critical, user still has premium in RevenueCat
    }
  }
}
