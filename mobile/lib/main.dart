import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_navigation.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/chat_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/revenuecat_service.dart';
import 'services/stable_user_id.dart';
import 'services/reading_progress_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize core services
  await _initializeServices();
  
  // Check if onboarding is completed (from AuthService)
  final showOnboarding = !AuthService().onboardingComplete;
  
  runApp(MyApp(showOnboarding: showOnboarding));
}

/// Initialize all core services before running the app
/// 
/// IMPORTANT: RevenueCat is configured ONLY HERE, ONCE.
/// Do NOT call Purchases.configure() anywhere else in the app.
Future<void> _initializeServices() async {
  // 1. Initialize authentication (device ID generation)
  await AuthService().initialize();
  
  // 2. Get stable user ID for RevenueCat
  // This ID persists across app restarts and NEVER changes
  final stableUserId = await StableUserIdService.I.initialize();
  
  debugPrint('');
  debugPrint('╔══════════════════════════════════════════════════════════════╗');
  debugPrint('║                    APP INITIALIZATION                         ║');
  debugPrint('╠══════════════════════════════════════════════════════════════╣');
  debugPrint('║ AuthService device ID: ${AuthService().deviceId}');
  debugPrint('║ Stable RevenueCat ID: $stableUserId');
  debugPrint('╚══════════════════════════════════════════════════════════════╝');
  debugPrint('');
  
  // 3. Initialize RevenueCat ONCE with stable user ID
  // CRITICAL: This is the ONLY place where RevenueCat is configured
  // - Uses stable appUserId that never changes
  // - Sets up customer info listener for reactive updates
  // - Fetches initial customer info and offerings
  await RevenueCatService.I.configureOnce(appUserId: stableUserId);
  
  // 4. Initialize reading progress service
  // Loads cached reading progress from local storage
  await ReadingProgressService().init();
  
  // Debug: Print full RevenueCat state
  RevenueCatService.I.debugPrintState();
  
  debugPrint('✅ All services initialized');
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Simple providers (no state changes)
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        
        // ChatProvider (reactive state)
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
        
        // Note: RevenueCatService uses ValueNotifier pattern instead of ChangeNotifier.
        // Access it via RevenueCatService.I or use ProAccess helper.
        // For reactive UI, use ValueListenableBuilder with RevenueCatService.I.isPro
      ],
      child: MaterialApp(
        title: 'Kur\'an Chat',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00A86B),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme,
          ),
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        ),
        home: showOnboarding ? const OnboardingScreen() : const MainNavigation(),
      ),
    );
  }
}

// =============================================================================
// USAGE EXAMPLES
// =============================================================================
// 
// 1. CHECK PRO STATUS (simple):
// ```dart
// import 'package:ayet_rehberi/services/pro_access.dart';
// 
// if (ProAccess.isPro) {
//   // Show premium feature
// }
// ```
//
// 2. REACTIVE PRO STATUS IN WIDGETS:
// ```dart
// ValueListenableBuilder<bool>(
//   valueListenable: RevenueCatService.I.isPro,
//   builder: (context, isPro, _) {
//     return isPro ? PremiumContent() : FreeContent();
//   },
// )
// ```
// 
// 3. PURCHASE A PACKAGE:
// ```dart
// final package = await RevenueCatService.I.getMonthlyPackage();
// if (package != null) {
//   final result = await RevenueCatService.I.buyPackage(package);
//   switch (result) {
//     case PurchaseSuccess():
//       // User is now Pro!
//       break;
//     case PurchaseCancelled():
//       // User cancelled
//       break;
//     case PurchaseFailed(:final error):
//       // Show error
//       break;
//   }
// }
// ```
//
// 4. RESTORE PURCHASES:
// ```dart
// final result = await RevenueCatService.I.restore();
// switch (result) {
//   case RestoreSuccess(:final isPro):
//     if (isPro) {
//       // Pro restored!
//     } else {
//       // No active subscription
//     }
//     break;
//   case RestoreFailed(:final error):
//     // Show error
//     break;
// }
// ```
//
// 5. ACCESS DEBUG SCREEN (hidden, for testing):
// ```dart
// Navigator.push(context, MaterialPageRoute(
//   builder: (_) => const RevenueCatDebugScreen(),
// ));
// ```
//
// =============================================================================
