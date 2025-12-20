import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'revenuecat_service.dart';

// =============================================================================
// PRO ACCESS HELPER
// =============================================================================
//
// Convenient helper for checking and listening to Pro status.
// Use this throughout your app for consistent Pro gating.
//
// Usage:
// ```dart
// // Simple boolean check
// if (ProAccess.isPro) {
//   // Show premium feature
// }
//
// // Reactive listener for UI
// ValueListenableBuilder<bool>(
//   valueListenable: ProAccess.proListenable,
//   builder: (context, isPro, _) {
//     return isPro ? PremiumWidget() : FreeWidget();
//   },
// )
// ```
//
// =============================================================================

/// Static helper for Pro access checks
class ProAccess {
  ProAccess._(); // Prevent instantiation

  /// Check if user currently has Pro access
  /// 
  /// Returns the current value of the isPro state.
  /// For reactive updates, use [proListenable] instead.
  static bool get isPro => RevenueCatService.I.isPro.value;

  /// Listenable for Pro status changes
  /// 
  /// Use with ValueListenableBuilder for reactive UI:
  /// ```dart
  /// ValueListenableBuilder<bool>(
  ///   valueListenable: ProAccess.proListenable,
  ///   builder: (context, isPro, _) {
  ///     return Text(isPro ? 'Pro User' : 'Free User');
  ///   },
  /// )
  /// ```
  static ValueListenable<bool> get proListenable => RevenueCatService.I.isPro;

  /// Check if RevenueCat is configured
  static bool get isConfigured => RevenueCatService.I.isConfigured;

  /// Get customer info listenable
  static ValueListenable<CustomerInfo?> get customerInfoListenable => 
      RevenueCatService.I.customerInfo;

  /// Get current subscription tier (weekly/monthly/yearly)
  static String? get currentTier => RevenueCatService.I.currentTier;

  /// Check if in trial period
  static bool get isInTrial => RevenueCatService.I.isInTrial;

  /// Get expiration date
  static DateTime? get expirationDate => RevenueCatService.I.expirationDate;

  /// Check if subscription will auto-renew
  static bool get willRenew => RevenueCatService.I.willRenew;
}
