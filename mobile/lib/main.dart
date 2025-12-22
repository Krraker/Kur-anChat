import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_navigation.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/chat_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/audio_service.dart';

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
Future<void> _initializeServices() async {
  // 1. Initialize authentication (device ID generation)
  await AuthService().initialize();
  
  // 2. Initialize subscription service (RevenueCat)
  await SubscriptionService().initialize();
  
  // 3. Link subscription to device ID for cross-device management
  final deviceId = AuthService().deviceId;
  if (deviceId != null) {
    await SubscriptionService().setUserId(deviceId);
  }
  
  // 4. Initialize audio service
  await QuranAudioService().init();
  
  debugPrint('All services initialized');
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<SubscriptionService>(
          create: (_) => SubscriptionService(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
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
