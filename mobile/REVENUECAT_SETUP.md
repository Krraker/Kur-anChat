# RevenueCat Integration - Kur'anChat Pro

## ✅ Dashboard Configuration (Already Complete)

| Item | Value |
|------|-------|
| **Entitlement** | `KuranChat_Pro` |
| **Products** | `kuranchat_pro_weekly`, `kuranchat_pro_monthly`, `kuranchat_pro_yearly` |
| **Offering** | `default` |
| **Packages** | `$rc_weekly`, `$rc_monthly`, `$rc_annual` |

## 📱 API Keys

Configured in `lib/services/subscription_service.dart`:

```dart
static const String _apiKeyIOS = 'test_FwDZqCnWjayUOGZaqpLYKjGtTcg';
static const String _apiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_API_KEY'; // TODO: Add
```

> ⚠️ **Note**: `test_` keys are for sandbox. Production keys start with `appl_` (iOS) or `goog_` (Android).

---

## 🚀 Quick Start

### Check Pro Status

```dart
// With Provider (reactive)
final sub = context.watch<SubscriptionService>();
if (sub.isPro) {
  // Show pro content
}

// Without Provider
if (SubscriptionService().isPro) {
  // Show pro content
}
```

### Show Paywall

```dart
// Option 1: Custom Paywall (ProPaywallScreen)
import 'package:ayet_rehberi/screens/paywall/pro_paywall_screen.dart';

final purchased = await showProPaywall(context, turkish: true);
if (purchased) {
  // User is now Pro!
}

// Option 2: RevenueCat Native Paywall
final result = await SubscriptionService().presentPaywall();
if (result == PaywallResult.purchased) {
  // User is now Pro!
}
```

### Gate Premium Features

```dart
// Using the ProFeatureGate mixin
class _MyScreenState extends State<MyScreen> with ProFeatureGate {
  void _onPremiumTap() {
    requirePro(
      context,
      onGranted: () => _unlockFeature(),
      onDenied: () => _showMessage('Upgrade to unlock'),
    );
  }
}

// Or manually
void _onPremiumTap() async {
  if (SubscriptionService().isPro) {
    _unlockFeature();
  } else {
    final purchased = await showProPaywall(context);
    if (purchased) _unlockFeature();
  }
}
```

### Restore Purchases

```dart
final restored = await SubscriptionService().restore();
if (restored) {
  // Pro restored!
}
```

### Show Customer Center

```dart
await SubscriptionService().presentCustomerCenter();
```

---

## 📂 Files

| File | Purpose |
|------|---------|
| `lib/services/subscription_service.dart` | Core RevenueCat integration |
| `lib/screens/paywall/pro_paywall_screen.dart` | Custom paywall UI |
| `lib/screens/onboarding/paywall_screen.dart` | Onboarding paywall (animated) |

---

## 🔧 SubscriptionService API

### Properties

```dart
bool get isInitialized;      // SDK initialized?
bool get isLoading;          // Purchase in progress?
bool get isPro;              // Has KuranChat_Pro entitlement?
String? get error;           // Last error message
List<Package> get packages;  // Available packages
Package? get weeklyPackage;  // Weekly package
Package? get monthlyPackage; // Monthly package
Package? get yearlyPackage;  // Yearly package
DateTime? get expirationDate;
bool get willRenew;
bool get isInTrial;
String? get currentTier;     // 'weekly', 'monthly', 'yearly'
int? get yearlySavingsPercent;
```

### Methods

```dart
// Initialization (call once in main.dart)
await initialize({String? appUserId});

// Load packages
await loadOfferings();

// Purchase
PurchaseResultType result = await purchase(package);
// Returns: success, cancelled, or failed

// Restore
bool restored = await restore();

// Refresh status
await refreshCustomerInfo();

// User management
await logIn(userId);
await logOut();

// RevenueCat UI
PaywallResult result = await presentPaywall();
PaywallResult result = await presentPaywallIfNeeded();
await presentCustomerCenter();

// Display helpers
String status = getStatusText(turkish: true);
// Returns: "Yıllık Pro", "Aylık Pro", "Ücretsiz", etc.
```

---

## 🍎 iOS Notes

### StoreKit Configuration

1. Ensure your bundle ID matches RevenueCat app configuration
2. In Xcode: Target → Signing & Capabilities → Add "In-App Purchase"
3. For testing: Use a Sandbox Apple ID

### After Purchase

RevenueCat automatically syncs purchases. If issues occur:

```dart
await SubscriptionService().refreshCustomerInfo();
// or
await SubscriptionService().restore();
```

### App Store Review

- Test purchases work in Sandbox before submission
- Include restore purchases button (required by Apple)
- Terms of Use / Privacy Policy links required

---

## 🤖 Android Notes

### Setup

1. Add Android API key to `subscription_service.dart`
2. Upload signed APK/AAB to Play Console for license testing
3. Add test accounts to License Testers

### Billing Library

RevenueCat handles Google Play Billing Library automatically.

---

## 🧪 Testing

### Sandbox Testing (iOS)

```dart
// Enable debug logs
await Purchases.setLogLevel(LogLevel.debug);

// Check current state
SubscriptionService().debugPrintState();
```

1. Sign out of App Store on device
2. Run app and attempt purchase
3. Sign in with Sandbox Apple ID when prompted
4. Sandbox subscriptions auto-renew quickly (weekly = 3 min)

### Test Scenarios

- [ ] Fresh install - no subscription
- [ ] Purchase weekly/monthly/yearly
- [ ] Cancel purchase midway
- [ ] Restore on new device
- [ ] Subscription expiration
- [ ] Upgrade/downgrade plans

---

## 📋 Checklist

- [x] Install `purchases_flutter` and `purchases_ui_flutter`
- [x] Configure iOS API key
- [ ] Configure Android API key
- [x] Create products in App Store Connect
- [x] Create entitlement `KuranChat_Pro` in RevenueCat
- [x] Create offering `default` with packages
- [x] Implement SubscriptionService
- [x] Implement ProPaywallScreen
- [x] Add Provider integration
- [ ] Test in iOS Sandbox
- [ ] Test on Android
- [ ] Switch to production API keys before release

---

## 🔗 Resources

- [RevenueCat Flutter Docs](https://www.revenuecat.com/docs/getting-started/installation/flutter)
- [Testing Guide](https://www.revenuecat.com/docs/test-and-launch/sandbox)
- [Paywalls](https://www.revenuecat.com/docs/tools/paywalls)
- [Customer Center](https://www.revenuecat.com/docs/tools/customer-center)




