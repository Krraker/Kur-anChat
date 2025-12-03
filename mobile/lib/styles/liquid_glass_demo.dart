import 'package:flutter/material.dart';
import 'global_app_style.dart';

/// Demo page showcasing the LiquidGlass widgets
/// 
/// Run this demo by temporarily changing your app's home to:
/// ```dart
/// home: const LiquidGlassDemo(),
/// ```
class LiquidGlassDemo extends StatelessWidget {
  const LiquidGlassDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Liquid Glass',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Frosted glass UI components',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Hero Card
                _buildSection('Card'),
                const SizedBox(height: 16),
                LiquidGlassCard(
                  height: 200,
                  variant: LiquidGlassVariant.intense,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 40,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Featured Content',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'With prominent glass effect',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Variant Comparison
                _buildSection('Variants'),
                const SizedBox(height: 16),
                ...[
                  ('Subtle', LiquidGlassVariant.subtle),
                  ('Standard', LiquidGlassVariant.standard),
                  ('Intense', LiquidGlassVariant.intense),
                  ('Frosted', LiquidGlassVariant.frosted),
                ].map((variant) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LiquidGlassCard(
                    height: 80,
                    variant: variant.$2,
                    child: Center(
                      child: Text(
                        variant.$1,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 36),

                // Buttons
                _buildSection('Buttons'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LiquidGlassButton(
                        onTap: () {},
                        child: Text(
                          'Primary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LiquidGlassButton(
                        onTap: () {},
                        child: Text(
                          'Secondary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Chips
                _buildSection('Chips'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    'Music',
                    'Videos',
                    'Photos',
                    'Documents',
                  ].map((label) => LiquidGlassChip(
                    onTap: () {},
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 48),

                // List Items
                _buildSection('List Items'),
                const SizedBox(height: 16),
                ...['First Item', 'Second Item', 'Third Item'].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LiquidGlassListItem(
                    onTap: () {},
                    child: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 48),

                // Navigation Bar
                _buildSection('Navigation Bar'),
                const SizedBox(height: 16),
                LiquidGlassNavigationBar(
                  margin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.home, 'Home', true),
                      _buildNavItem(Icons.search, 'Search', false),
                      _buildNavItem(Icons.favorite, 'Favorites', false),
                      _buildNavItem(Icons.person, 'Profile', false),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.6),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: Colors.white.withOpacity(isActive ? 0.9 : 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(isActive ? 0.9 : 0.5),
          ),
        ),
      ],
    );
  }
}

/// Minimal main() for testing the LiquidGlass widgets
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LiquidGlassDemo(),
    ),
  );
}
