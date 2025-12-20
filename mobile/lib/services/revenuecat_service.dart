import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// =============================================================================
// REVENUECAT SERVICE - SINGLE-INIT, STABLE ENTITLEMENT MANAGEMENT
// =============================================================================
//
// IMPORTANT: This service follows a SINGLE CONFIGURE pattern.
// - Call configureOnce() EXACTLY ONCE at app startup (in main.dart)
// - NEVER call Purchases.configure() anywhere else in the app
// - Use the listener-based entitlement updates for reactive UI
// - appUserId MUST remain stable across app restarts
//
// Configuration:
// - Entitlement ID: KuranChat_Pro
// - Offering: default
// - Packages: $rc_weekly, $rc_monthly, $rc_annual
//
// =============================================================================

/// Singleton RevenueCat service with bulletproof initialization
/// 
/// Usage:
/// ```dart
/// // In main.dart ONLY, after getting stable userId:
/// await RevenueCatService.I.configureOnce(
///   apiKey: 'your_api_key',
///   appUserId: stableUserId,
/// );
/// 
/// // In widgets:
/// ValueListenableBuilder<bool>(
///   valueListenable: RevenueCatService.I.isPro,
///   builder: (context, isPro, _) {
///     return isPro ? PremiumWidget() : FreeWidget();
///   },
/// )
/// ```
class RevenueCatService {
  // ===========================================================================
  // SINGLETON
  // ===========================================================================
  
  static final RevenueCatService _instance = RevenueCatService._internal();
  
  /// Singleton instance - use this everywhere
  static RevenueCatService get I => _instance;
  
  RevenueCatService._internal();

  // ===========================================================================
  // CONFIGURATION - Match your RevenueCat Dashboard exactly
  // ===========================================================================
  
  /// RevenueCat API Keys
  /// Test keys start with 'test_', production with 'appl_' or 'goog_'
  static const String _apiKeyIOS = 'test_FwDZqCnWjayUOGZaqpLYKjGtTcg';
  static const String _apiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_API_KEY'; // TODO: Add Android key
  
  /// Entitlement ID - MUST match exactly what's in RevenueCat dashboard
  /// This is checked to determine Pro status
  static const String entitlementId = 'KuranChat_Pro';
  
  /// Offering identifier
  static const String offeringId = 'default';

  // ===========================================================================
  // STATE - Use ValueNotifier for reactive updates
  // ===========================================================================
  
  /// Guard to ensure configure is called only once
  bool _configured = false;
  
  /// Whether user has active KuranChat_Pro entitlement
  final ValueNotifier<bool> isPro = ValueNotifier<bool>(false);
  
  /// Current customer info from RevenueCat
  final ValueNotifier<CustomerInfo?> customerInfo = ValueNotifier<CustomerInfo?>(null);
  
  /// Loading state for UI
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  
  /// Last error message
  String? _lastError;
  String? get lastError => _lastError;
  
  /// Current offerings cache
  Offerings? _offerings;
  
  /// Stable app user ID used for configuration
  String? _appUserId;
  String? get appUserId => _appUserId;
  
  /// Whether SDK is configured
  bool get isConfigured => _configured;

  // ===========================================================================
  // INITIALIZATION - CALL ONLY ONCE AT APP STARTUP
  // ===========================================================================
  
  /// Configure RevenueCat SDK - CALL ONLY ONCE in main.dart
  /// 
  /// [appUserId] - Stable user ID that NEVER changes across app restarts.
  ///               Use AuthService.deviceId or a persistent UUID.
  /// 
  /// IMPORTANT: 
  /// - This method is guarded and will no-op if called multiple times
  /// - Do NOT call this from widget build methods
  /// - Do NOT call Purchases.configure() anywhere else
  Future<void> configureOnce({required String appUserId}) async {
    // Guard: prevent multiple configurations
    if (_configured) {
      debugPrint('⚠️ RevenueCatService: Already configured, skipping.');
      debugPrint('   Current appUserId: $_appUserId');
      return;
    }

    _appUserId = appUserId;
    
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════════╗');
    debugPrint('║           REVENUECAT SERVICE - CONFIGURING                   ║');
    debugPrint('╠══════════════════════════════════════════════════════════════╣');
    debugPrint('║ appUserId: $appUserId');
    debugPrint('╚══════════════════════════════════════════════════════════════╝');
    debugPrint('');

    try {
      // 1. Set log level for debugging
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

      // 2. Get platform-specific API key
      final String apiKey;
      if (Platform.isIOS || Platform.isMacOS) {
        apiKey = _apiKeyIOS;
      } else if (Platform.isAndroid) {
        apiKey = _apiKeyAndroid;
        if (apiKey == 'YOUR_REVENUECAT_ANDROID_API_KEY') {
          debugPrint('⚠️ RevenueCatService: Android API key not configured!');
        }
      } else {
        debugPrint('RevenueCatService: Unsupported platform');
        return;
      }

      // 3. Configure RevenueCat with stable appUserId
      // IMPORTANT: appUserID is set here and should NEVER change
      final configuration = PurchasesConfiguration(apiKey)
        ..appUserID = appUserId;
      
      await Purchases.configure(configuration);
      _configured = true;

      // 4. Register customer info update listener
      // This listener fires whenever entitlements change:
      // - After purchase
      // - After restore
      // - On subscription renewal/expiration
      // - On app foreground if status changed
      Purchases.addCustomerInfoUpdateListener((info) {
        _applyCustomerInfo(info, source: 'listener');
      });

      // 5. Fetch initial customer info
      final initialInfo = await Purchases.getCustomerInfo();
      _applyCustomerInfo(initialInfo, source: 'initial');

      // 6. Prefetch offerings
      await _loadOfferings();

      debugPrint('');
      debugPrint('✅ RevenueCatService: Configured successfully');
      debugPrint('   originalAppUserId: ${initialInfo.originalAppUserId}');
      debugPrint('   isPro: ${isPro.value}');
      debugPrint('');

    } catch (e, stackTrace) {
      _lastError = 'Configuration failed: $e';
      debugPrint('❌ RevenueCatService: $_lastError');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  // ===========================================================================
  // CUSTOMER INFO PROCESSING
  // ===========================================================================
  
  /// Apply customer info and update state
  /// Logs detailed debug info for troubleshooting
  void _applyCustomerInfo(CustomerInfo info, {required String source}) {
    customerInfo.value = info;
    
    // Check for KuranChat_Pro entitlement
    final entitlement = info.entitlements.active[entitlementId];
    final wasProBefore = isPro.value;
    isPro.value = entitlement != null;

    // Debug logging
    debugPrint('');
    debugPrint('┌─────────────────────────────────────────────────────────────┐');
    debugPrint('│ RevenueCatService._applyCustomerInfo                        │');
    debugPrint('├─────────────────────────────────────────────────────────────┤');
    debugPrint('│ Source: $source');
    debugPrint('│ originalAppUserId: ${info.originalAppUserId}');
    debugPrint('│ Active Entitlements: ${info.entitlements.active.keys.toList()}');
    debugPrint('│ isPro: ${isPro.value} (was: $wasProBefore)');
    if (entitlement != null) {
      debugPrint('│ ─────────────────────────────────────────────────────────────');
      debugPrint('│ $entitlementId Details:');
      debugPrint('│   productIdentifier: ${entitlement.productIdentifier}');
      debugPrint('│   expirationDate: ${entitlement.expirationDate ?? "Never"}');
      debugPrint('│   willRenew: ${entitlement.willRenew}');
      debugPrint('│   periodType: ${entitlement.periodType}');
      debugPrint('│   isActive: ${entitlement.isActive}');
    }
    debugPrint('└─────────────────────────────────────────────────────────────┘');
    debugPrint('');
  }

  // ===========================================================================
  // OFFERINGS
  // ===========================================================================
  
  /// Load offerings from RevenueCat (called during init)
  Future<void> _loadOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      debugPrint('RevenueCatService: Loaded offerings');
      if (_offerings?.current != null) {
        debugPrint('   Current offering: ${_offerings!.current!.identifier}');
        debugPrint('   Packages: ${_offerings!.current!.availablePackages.length}');
      }
    } catch (e) {
      debugPrint('RevenueCatService: Error loading offerings: $e');
    }
  }

  /// Get offerings (fetches fresh if not cached)
  Future<Offerings> getOfferings() async {
    if (_offerings != null) return _offerings!;
    
    _offerings = await Purchases.getOfferings();
    return _offerings!;
  }

  /// Get the default offering
  Future<Offering?> getDefaultOffering() async {
    final offerings = await getOfferings();
    return offerings.getOffering(offeringId) ?? offerings.current;
  }

  /// Get specific packages from default offering
  Future<List<Package>> getPackages() async {
    final offering = await getDefaultOffering();
    return offering?.availablePackages ?? [];
  }

  /// Get weekly package ($rc_weekly)
  Future<Package?> getWeeklyPackage() async {
    final packages = await getPackages();
    return packages.cast<Package?>().firstWhere(
      (p) => p?.packageType == PackageType.weekly,
      orElse: () => null,
    );
  }

  /// Get monthly package ($rc_monthly)
  Future<Package?> getMonthlyPackage() async {
    final packages = await getPackages();
    return packages.cast<Package?>().firstWhere(
      (p) => p?.packageType == PackageType.monthly,
      orElse: () => null,
    );
  }

  /// Get yearly/annual package ($rc_annual)
  Future<Package?> getYearlyPackage() async {
    final packages = await getPackages();
    return packages.cast<Package?>().firstWhere(
      (p) => p?.packageType == PackageType.annual,
      orElse: () => null,
    );
  }

  // ===========================================================================
  // PURCHASE
  // ===========================================================================
  
  /// Purchase a package
  /// 
  /// After purchase, the listener will automatically update isPro.
  /// Returns the result type for UI handling.
  Future<PurchaseResult> buyPackage(Package package) async {
    if (isLoading.value) {
      return PurchaseResult.failed(error: 'Purchase already in progress');
    }

    isLoading.value = true;
    _lastError = null;

    try {
      debugPrint('RevenueCatService: Purchasing ${package.storeProduct.identifier}...');
      
      // ignore: deprecated_member_use
      final result = await Purchases.purchasePackage(package);
      
      // Apply immediately (listener will also fire)
      _applyCustomerInfo(result.customerInfo, source: 'purchase');
      
      isLoading.value = false;
      
      if (isPro.value) {
        debugPrint('✅ Purchase successful! KuranChat_Pro is now active');
        return PurchaseResult.success();
      } else {
        debugPrint('⚠️ Purchase completed but entitlement not active');
        return PurchaseResult.failed(error: 'Entitlement not active after purchase');
      }
      
    } on PurchasesErrorCode catch (errorCode) {
      isLoading.value = false;
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('RevenueCatService: User cancelled purchase');
        return PurchaseResult.cancelled();
      }
      
      _lastError = _getErrorMessage(errorCode);
      debugPrint('❌ Purchase error: $errorCode');
      return PurchaseResult.failed(error: _lastError);
      
    } catch (e) {
      isLoading.value = false;
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('cancel')) {
        debugPrint('RevenueCatService: User cancelled purchase');
        return PurchaseResult.cancelled();
      }
      
      _lastError = 'Purchase failed. Please try again.';
      debugPrint('❌ Purchase error: $e');
      return PurchaseResult.failed(error: _lastError);
    }
  }

  // ===========================================================================
  // RESTORE
  // ===========================================================================
  
  /// Restore previous purchases
  /// 
  /// After restore, the listener will automatically update isPro.
  Future<RestoreResult> restore() async {
    if (isLoading.value) {
      return RestoreResult.failed(error: 'Operation in progress');
    }

    isLoading.value = true;
    _lastError = null;

    try {
      debugPrint('RevenueCatService: Restoring purchases...');
      
      final info = await Purchases.restorePurchases();
      
      // Apply immediately (listener will also fire)
      _applyCustomerInfo(info, source: 'restore');
      
      isLoading.value = false;
      
      if (isPro.value) {
        debugPrint('✅ Restore successful - KuranChat_Pro restored!');
        return RestoreResult.success(isPro: true);
      } else {
        debugPrint('ℹ️ Restore completed - No active subscription found');
        return RestoreResult.success(isPro: false);
      }
      
    } catch (e) {
      isLoading.value = false;
      _lastError = 'Restore failed. Please try again.';
      debugPrint('❌ Restore error: $e');
      return RestoreResult.failed(error: _lastError);
    }
  }

  // ===========================================================================
  // REFRESH
  // ===========================================================================
  
  /// Force refresh customer info from server
  /// Useful when app comes to foreground
  Future<void> refreshCustomerInfo() async {
    if (!_configured) return;
    
    try {
      final info = await Purchases.getCustomerInfo();
      _applyCustomerInfo(info, source: 'refresh');
    } catch (e) {
      debugPrint('RevenueCatService: Error refreshing: $e');
    }
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================
  
  /// Get user-friendly error message
  String? _getErrorMessage(PurchasesErrorCode code) {
    switch (code) {
      case PurchasesErrorCode.purchaseCancelledError:
        return null; // Not an error
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchases are not allowed on this device.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'Invalid purchase. Please try again.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'This product is not available.';
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.storeProblemError:
        return 'App Store error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Get expiration date of current subscription
  DateTime? get expirationDate {
    final entitlement = customerInfo.value?.entitlements.active[entitlementId];
    if (entitlement?.expirationDate != null) {
      return DateTime.parse(entitlement!.expirationDate!);
    }
    return null;
  }

  /// Check if subscription will auto-renew
  bool get willRenew {
    return customerInfo.value?.entitlements.active[entitlementId]?.willRenew ?? false;
  }

  /// Check if user is in trial period
  bool get isInTrial {
    return customerInfo.value?.entitlements.active[entitlementId]?.periodType == PeriodType.trial;
  }

  /// Get current subscription tier
  String? get currentTier {
    final productId = customerInfo.value?.entitlements.active[entitlementId]?.productIdentifier;
    if (productId == null) return null;
    
    if (productId.contains('weekly')) return 'weekly';
    if (productId.contains('monthly')) return 'monthly';
    if (productId.contains('yearly')) return 'yearly';
    return productId;
  }

  /// Print comprehensive debug state
  void debugPrintState() {
    debugPrint('');
    debugPrint('╔══════════════════════════════════════════════════════════════╗');
    debugPrint('║              REVENUECAT SERVICE DEBUG STATE                  ║');
    debugPrint('╠══════════════════════════════════════════════════════════════╣');
    debugPrint('║ Configured: $_configured');
    debugPrint('║ appUserId: $_appUserId');
    debugPrint('║ isPro: ${isPro.value}');
    debugPrint('║ Entitlement ID: $entitlementId');
    debugPrint('║ currentTier: $currentTier');
    debugPrint('║ expirationDate: $expirationDate');
    debugPrint('║ willRenew: $willRenew');
    debugPrint('║ isInTrial: $isInTrial');
    debugPrint('║ lastError: $_lastError');
    if (customerInfo.value != null) {
      debugPrint('║ ──────────────────────────────────────────────────────────────');
      debugPrint('║ originalAppUserId: ${customerInfo.value!.originalAppUserId}');
      debugPrint('║ Active entitlements: ${customerInfo.value!.entitlements.active.keys}');
      debugPrint('║ All entitlements: ${customerInfo.value!.entitlements.all.keys}');
    }
    debugPrint('╚══════════════════════════════════════════════════════════════╝');
    debugPrint('');
  }
}

// =============================================================================
// RESULT TYPES
// =============================================================================

/// Result of a purchase attempt
sealed class PurchaseResult {
  const PurchaseResult();
  
  factory PurchaseResult.success() = PurchaseSuccess;
  factory PurchaseResult.cancelled() = PurchaseCancelled;
  factory PurchaseResult.failed({String? error}) = PurchaseFailed;
  
  bool get isSuccess => this is PurchaseSuccess;
  bool get isCancelled => this is PurchaseCancelled;
  bool get isFailed => this is PurchaseFailed;
}

class PurchaseSuccess extends PurchaseResult {
  const PurchaseSuccess();
}

class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

class PurchaseFailed extends PurchaseResult {
  final String? error;
  const PurchaseFailed({this.error});
}

/// Result of a restore attempt
sealed class RestoreResult {
  const RestoreResult();
  
  factory RestoreResult.success({required bool isPro}) = RestoreSuccess;
  factory RestoreResult.failed({String? error}) = RestoreFailed;
}

class RestoreSuccess extends RestoreResult {
  final bool isPro;
  const RestoreSuccess({required this.isPro});
}

class RestoreFailed extends RestoreResult {
  final String? error;
  const RestoreFailed({this.error});
}

