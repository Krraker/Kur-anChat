# 💳 RevenueCat Integration Guide

> RevenueCat handles all the complexity of in-app purchases. It's free until you make $2.5M.

---

## Step 1: Create RevenueCat Account

1. Go to https://app.revenuecat.com
2. Sign up with your email
3. Create a new Project called "KuranChat"

---

## Step 2: Add Package to Flutter

```bash
cd /Users/cemyonetim/Development/KuranChat/mobile
flutter pub add purchases_flutter
```

---

## Step 3: iOS Setup

### 3.1 Create App in App Store Connect

1. Go to https://appstoreconnect.apple.com
2. Click "My Apps" → "+" → "New App"
3. Fill in:
   - Platform: iOS
   - Name: Kuran Chat (or your app name)
   - Primary Language: Turkish
   - Bundle ID: `com.example.ayet_rehberi` (change to your actual bundle ID)
   - SKU: `kuranchat-ios`

### 3.2 Create Subscriptions

1. In your app → "Subscriptions" tab
2. Create Subscription Group: "KuranChat Premium"
3. Create 3 subscriptions:

| Reference Name | Product ID | Price | Duration |
|----------------|------------|-------|----------|
| Weekly | `kuranchat_weekly` | $2.99 | 1 Week |
| Monthly | `kuranchat_monthly` | $9.99 | 1 Month |
| Yearly | `kuranchat_yearly` | $59.99 | 1 Year |

For each subscription:
- Add Display Name (e.g., "Haftalık Premium")
- Add Description
- Set price in all territories

### 3.3 Get Shared Secret

1. App Store Connect → Your App → "App Information"
2. Scroll to "App-Specific Shared Secret"
3. Click "Manage" → "Generate"
4. Copy the secret

### 3.4 Connect to RevenueCat

1. RevenueCat Dashboard → Your Project → iOS App
2. Paste Shared Secret
3. Add Bundle ID

---

## Step 4: Android Setup

### 4.1 Create App in Google Play Console

1. Go to https://play.google.com/console
2. Create new app
3. Fill in app details

### 4.2 Create Subscriptions

1. Monetize → Products → Subscriptions
2. Create same 3 products:

| Product ID | Price | Duration |
|------------|-------|----------|
| `kuranchat_weekly` | $2.99 | 1 Week |
| `kuranchat_monthly` | $9.99 | 1 Month |
| `kuranchat_yearly` | $59.99 | 1 Year |

### 4.3 Service Account for RevenueCat

1. Google Cloud Console → Create Service Account
2. Grant "Pub/Sub Admin" role
3. Download JSON key
4. In Play Console → Users & Permissions → Invite user
5. Add service account email with "Admin" access
6. Upload JSON to RevenueCat

---

## Step 5: Code Implementation

### 5.1 Create Subscription Service

Create `mobile/lib/services/subscription_service.dart`:

```dart
import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static const String _apiKeyIOS = 'YOUR_REVENUECAT_IOS_KEY';
  static const String _apiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_KEY';
  
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  bool _isInitialized = false;
  bool _isPremium = false;
  
  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await Purchases.setLogLevel(LogLevel.debug);
    
    PurchasesConfiguration configuration;
    if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyIOS);
    } else {
      configuration = PurchasesConfiguration(_apiKeyAndroid);
    }
    
    await Purchases.configure(configuration);
    _isInitialized = true;
    
    // Check initial subscription status
    await checkSubscriptionStatus();
    
    // Listen for changes
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      _updatePremiumStatus(customerInfo);
    });
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);
    } catch (e) {
      print('Error checking subscription: $e');
    }
  }

  void _updatePremiumStatus(CustomerInfo customerInfo) {
    _isPremium = customerInfo.entitlements.active.containsKey('premium');
  }

  Future<List<Package>> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      print('Error getting offerings: $e');
    }
    return [];
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      _updatePremiumStatus(customerInfo);
      return _isPremium;
    } catch (e) {
      print('Error purchasing: $e');
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      _updatePremiumStatus(customerInfo);
      return _isPremium;
    } catch (e) {
      print('Error restoring: $e');
      return false;
    }
  }

  // Link to your user ID (optional but recommended)
  Future<void> setUserId(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }
}
```

### 5.2 Initialize in main.dart

```dart
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize RevenueCat
  await SubscriptionService().initialize();
  
  runApp(const MyApp());
}
```

### 5.3 Update PaywallScreen

In `paywall_screen.dart`, connect the "Subscribe" button:

```dart
// Add this import
import '../../services/subscription_service.dart';

// In your state class, add:
List<Package> _packages = [];
bool _isLoading = true;

@override
void initState() {
  super.initState();
  _loadOfferings();
  // ... existing animation code
}

Future<void> _loadOfferings() async {
  final packages = await SubscriptionService().getOfferings();
  if (mounted) {
    setState(() {
      _packages = packages;
      _isLoading = false;
    });
  }
}

Future<void> _purchaseSelected() async {
  if (_packages.isEmpty) return;
  
  setState(() => _isLoading = true);
  
  final success = await SubscriptionService().purchasePackage(
    _packages[_selectedPlan]
  );
  
  if (mounted) {
    setState(() => _isLoading = false);
    if (success) {
      widget.onContinue();
    }
  }
}
```

---

## Step 6: Create Entitlement in RevenueCat

1. RevenueCat Dashboard → Your Project → Entitlements
2. Create new entitlement: `premium`
3. Attach all 3 subscription products to this entitlement

---

## Step 7: Test

### Sandbox Testing (iOS)
1. App Store Connect → Users and Access → Sandbox Testers
2. Create a test account
3. On device: Settings → App Store → Sign out
4. In app, purchase will prompt for sandbox login

### Test Purchases (Android)
1. Play Console → License Testing
2. Add your Gmail as a tester
3. Purchases will be free in testing mode

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Product not found" | Check product IDs match exactly |
| iOS purchases fail | Verify Shared Secret in RevenueCat |
| Android purchases fail | Check Service Account permissions |
| Sandbox not working | Sign out of real App Store account |

---

## RevenueCat API Keys

After setup, you'll find your API keys at:
- RevenueCat Dashboard → Your Project → API Keys

You need:
- iOS Public API Key
- Android Public API Key

Replace `YOUR_REVENUECAT_IOS_KEY` and `YOUR_REVENUECAT_ANDROID_KEY` in the code.

---

*Once purchases work in sandbox, you're ready for the next step!*




