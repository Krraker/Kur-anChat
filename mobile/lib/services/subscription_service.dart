// =============================================================================
// SUBSCRIPTION SERVICE - LEGACY WRAPPER
// =============================================================================
//
// ⚠️ DEPRECATED: This file is kept for backward compatibility only.
//
// Use RevenueCatService.I instead:
// - RevenueCatService.I.isPro.value for Pro status
// - RevenueCatService.I.buyPackage(pkg) for purchases
// - RevenueCatService.I.restore() for restore
//
// The new RevenueCatService provides:
// - Single-init pattern (configure only once in main.dart)
// - Stable appUserId across restarts
// - Listener-based entitlement updates
// - No "PRO gidip geliyor" issues
//
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'revenuecat_service.dart';

/// @Deprecated('Use RevenueCatService.I instead')
/// 
/// Legacy wrapper that delegates to RevenueCatService.
/// Kept for backward compatibility with existing code.
class SubscriptionService extends ChangeNotifier {
  // ===========================================================================
  // CONFIGURATION - Match RevenueCatService
  // ===========================================================================
  
  /// Entitlement ID - MUST match exactly what's in RevenueCat dashboard
  static const String entitlementId = 'KuranChat_Pro';
  
  /// Offering identifier - use 'default' or your custom offering ID
  static const String offeringId = 'default';

  // ===========================================================================
  // SINGLETON PATTERN
  // ===========================================================================
  
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal() {
    // Listen to RevenueCatService changes and forward notifications
    RevenueCatService.I.isPro.addListener(_onProChanged);
    RevenueCatService.I.customerInfo.addListener(_onCustomerInfoChanged);
  }

  void _onProChanged() {
    notifyListeners();
  }

  void _onCustomerInfoChanged() {
    notifyListeners();
  }

  // ===========================================================================
  // GETTERS - Delegate to RevenueCatService
  // ===========================================================================
  
  /// Whether RevenueCat SDK is initialized
  bool get isInitialized => RevenueCatService.I.isConfigured;
  
  /// Whether a purchase/restore operation is in progress
  bool get isLoading => RevenueCatService.I.isLoading.value;
  
  /// Whether user has active KuranChat_Pro entitlement
  bool get isPro => RevenueCatService.I.isPro.value;
  
  /// Last error message (null if no error)
  String? get error => RevenueCatService.I.lastError;
  
  /// Current customer info from RevenueCat
  CustomerInfo? get customerInfo => RevenueCatService.I.customerInfo.value;
  
  /// Current offering with packages - loaded lazily
  Offering? _currentOffering;
  Offering? get currentOffering => _currentOffering;
  
  /// Available packages (weekly, monthly, yearly)
  List<Package> _packages = [];
  List<Package> get packages => _packages;
  
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
  
  /// Get yearly/annual package
  Package? get yearlyPackage => _packages.cast<Package?>().firstWhere(
    (p) => p?.packageType == PackageType.annual,
    orElse: () => null,
  );

  // ===========================================================================
  // INITIALIZATION - Delegate to RevenueCatService
  // ===========================================================================
  
  /// @Deprecated('RevenueCat is now initialized in main.dart')
  /// 
  /// This method is kept for backward compatibility but does nothing.
  /// RevenueCat is configured once in main.dart via RevenueCatService.I.configureOnce()
  Future<void> initialize({String? appUserId}) async {
    debugPrint('⚠️ SubscriptionService.initialize() called but ignored.');
    debugPrint('   RevenueCat is now configured once in main.dart');
    debugPrint('   Use RevenueCatService.I instead');
    
    // Load packages if not already loaded
    if (_packages.isEmpty) {
      await loadOfferings();
    }
  }

  // ===========================================================================
  // OFFERINGS & PACKAGES
  // ===========================================================================
  
  /// Load offerings from RevenueCat
  Future<void> loadOfferings() async {
    try {
      final offerings = await RevenueCatService.I.getOfferings();
      
      _currentOffering = offerings.getOffering(offeringId) ?? offerings.current;
      
      if (_currentOffering != null) {
        _packages = _currentOffering!.availablePackages;
        debugPrint('SubscriptionService: Loaded ${_packages.length} packages');
      } else {
        _packages = [];
      }
      
      notifyListeners();
      
    } catch (e) {
      debugPrint('SubscriptionService: Error loading offerings: $e');
    }
  }

  // ===========================================================================
  // PURCHASE
  // ===========================================================================
  
  /// Purchase a subscription package
  Future<PurchaseResultType> purchase(Package package) async {
    final result = await RevenueCatService.I.buyPackage(package);
    
    notifyListeners();
    
    switch (result) {
      case PurchaseSuccess():
        return PurchaseResultType.success;
      case PurchaseCancelled():
        return PurchaseResultType.cancelled;
      case PurchaseFailed():
        return PurchaseResultType.failed;
    }
  }

  // ===========================================================================
  // RESTORE PURCHASES
  // ===========================================================================
  
  /// Restore previous purchases
  Future<bool> restore() async {
    final result = await RevenueCatService.I.restore();
    
    notifyListeners();
    
    switch (result) {
      case RestoreSuccess(:final isPro):
        return isPro;
      case RestoreFailed():
        return false;
    }
  }

  // ===========================================================================
  // REFRESH CUSTOMER INFO
  // ===========================================================================
  
  /// Refresh customer info from RevenueCat
  Future<void> refreshCustomerInfo() async {
    await RevenueCatService.I.refreshCustomerInfo();
    notifyListeners();
  }

  // ===========================================================================
  // USER MANAGEMENT - REMOVED
  // ===========================================================================
  
  /// @Deprecated('logIn is not used - appUserId is set at configure time')
  /// 
  /// This method is kept for backward compatibility but does nothing.
  /// The appUserId is now set once during configuration and never changes.
  Future<void> logIn(String userId) async {
    debugPrint('⚠️ SubscriptionService.logIn() called but ignored.');
    debugPrint('   appUserId is set once at configure time and should not change.');
    debugPrint('   Changing user ID can cause entitlement issues.');
  }

  /// @Deprecated('logOut is not used - will cause entitlement issues')
  /// 
  /// This method is kept for backward compatibility but does nothing.
  /// Logging out would create a new anonymous user and lose entitlements.
  Future<void> logOut() async {
    debugPrint('⚠️ SubscriptionService.logOut() called but ignored.');
    debugPrint('   Logging out would cause entitlement issues.');
    debugPrint('   Only log out when user explicitly signs out of the app.');
  }

  // ===========================================================================
  // REVENUECAT NATIVE PAYWALL
  // ===========================================================================
  
  /// Present RevenueCat's native paywall UI
  Future<PaywallResult> presentPaywall({bool displayCloseButton = true}) async {
    try {
      return await RevenueCatUI.presentPaywall(
        displayCloseButton: displayCloseButton,
        offering: _currentOffering,
      );
    } catch (e) {
      debugPrint('SubscriptionService: Error presenting paywall: $e');
      return PaywallResult.error;
    }
  }

  /// Present paywall only if user is not Pro
  Future<PaywallResult> presentPaywallIfNeeded() async {
    try {
      return await RevenueCatUI.presentPaywallIfNeeded(
        entitlementId,
        offering: _currentOffering,
      );
    } catch (e) {
      debugPrint('SubscriptionService: Error presenting paywall: $e');
      return PaywallResult.error;
    }
  }

  // ===========================================================================
  // CUSTOMER CENTER
  // ===========================================================================
  
  /// Present RevenueCat's Customer Center
  Future<void> presentCustomerCenter() async {
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('SubscriptionService: Error presenting customer center: $e');
    }
  }

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================
  
  /// Get expiration date of current subscription
  DateTime? get expirationDate => RevenueCatService.I.expirationDate;

  /// Check if subscription will auto-renew
  bool get willRenew => RevenueCatService.I.willRenew;

  /// Check if user is in trial period
  bool get isInTrial => RevenueCatService.I.isInTrial;

  /// Get current subscription tier (weekly/monthly/yearly)
  String? get currentTier => RevenueCatService.I.currentTier;

  /// Calculate savings for yearly vs monthly
  int? get yearlySavingsPercent {
    final monthly = monthlyPackage;
    final yearly = yearlyPackage;
    
    if (monthly == null || yearly == null) return null;
    
    final monthlyYearCost = monthly.storeProduct.price * 12;
    final yearlyCost = yearly.storeProduct.price;
    
    if (monthlyYearCost <= 0) return null;
    
    return (((monthlyYearCost - yearlyCost) / monthlyYearCost) * 100).round();
  }

  /// Get localized subscription status text
  String getStatusText({bool turkish = true}) {
    if (!isPro) {
      return turkish ? 'Ücretsiz' : 'Free';
    }
    
    if (isInTrial) {
      return turkish ? 'Deneme Sürümü' : 'Trial';
    }
    
    switch (currentTier) {
      case 'weekly':
        return turkish ? 'Haftalık Pro' : 'Weekly Pro';
      case 'monthly':
        return turkish ? 'Aylık Pro' : 'Monthly Pro';
      case 'yearly':
        return turkish ? 'Yıllık Pro' : 'Yearly Pro';
      default:
        return turkish ? 'Pro' : 'Pro';
    }
  }

  // ===========================================================================
  // DEBUG
  // ===========================================================================
  
  /// Print debug info about current subscription state
  void debugPrintState() {
    RevenueCatService.I.debugPrintState();
  }
}

// =============================================================================
// PURCHASE RESULT ENUM
// =============================================================================

/// Result of a purchase attempt
enum PurchaseResultType {
  /// Purchase completed successfully, user now has Pro access
  success,
  
  /// User cancelled the purchase (not an error)
  cancelled,
  
  /// Purchase failed due to an error
  failed,
}

// =============================================================================
// FEATURE GATE MIXIN
// =============================================================================

/// Mixin to easily gate premium features in widgets
/// 
/// Usage:
/// ```dart
/// class _MyScreenState extends State<MyScreen> with ProFeatureGate {
///   void _onPremiumButtonPressed() {
///     requirePro(
///       context,
///       onGranted: () {
///         // User has Pro - do the premium thing
///       },
///     );
///   }
/// }
/// ```
mixin ProFeatureGate {
  /// Check if user has Pro access, show paywall if not
  Future<void> requirePro(
    BuildContext context, {
    required VoidCallback onGranted,
    VoidCallback? onDenied,
  }) async {
    // Use new service directly
    if (RevenueCatService.I.isPro.value) {
      onGranted();
      return;
    }
    
    // Show paywall
    final subscriptionService = SubscriptionService();
    final result = await subscriptionService.presentPaywallIfNeeded();
    
    if (result == PaywallResult.purchased || result == PaywallResult.restored) {
      onGranted();
    } else {
      onDenied?.call();
    }
  }
}
