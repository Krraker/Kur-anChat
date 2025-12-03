import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_navigation.dart';
import 'providers/chat_provider.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(
            apiService: context.read<ApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Ayet Rehberi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF22c55e),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.ebGaramondTextTheme().copyWith(
            // Headings
            displayLarge: GoogleFonts.ebGaramond(fontSize: 60, fontWeight: FontWeight.w400),
            displayMedium: GoogleFonts.ebGaramond(fontSize: 48, fontWeight: FontWeight.w400),
            displaySmall: GoogleFonts.ebGaramond(fontSize: 39, fontWeight: FontWeight.w400),
            headlineLarge: GoogleFonts.ebGaramond(fontSize: 35, fontWeight: FontWeight.w600),
            headlineMedium: GoogleFonts.ebGaramond(fontSize: 31, fontWeight: FontWeight.w600),
            headlineSmall: GoogleFonts.ebGaramond(fontSize: 27, fontWeight: FontWeight.w600),
            titleLarge: GoogleFonts.ebGaramond(fontSize: 25, fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.ebGaramond(fontSize: 21, fontWeight: FontWeight.w500),
            titleSmall: GoogleFonts.ebGaramond(fontSize: 19, fontWeight: FontWeight.w500),
            // Body text
            bodyLarge: GoogleFonts.ebGaramond(fontSize: 27, fontWeight: FontWeight.w400, height: 1.5),
            bodyMedium: GoogleFonts.ebGaramond(fontSize: 25, fontWeight: FontWeight.w400, height: 1.5),
            bodySmall: GoogleFonts.ebGaramond(fontSize: 22, fontWeight: FontWeight.w400, height: 1.4),
            // Labels
            labelLarge: GoogleFonts.ebGaramond(fontSize: 19, fontWeight: FontWeight.w500),
            labelMedium: GoogleFonts.ebGaramond(fontSize: 17, fontWeight: FontWeight.w500),
            labelSmall: GoogleFonts.ebGaramond(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: const MainNavigation(),
      ),
    );
  }
}


