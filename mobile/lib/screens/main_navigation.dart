import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'quran_screen.dart';
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';

/// Navigation controller to allow tab switching from anywhere
class NavigationController extends ChangeNotifier {
  int _currentIndex = 2; // Start with "Today" (Home) tab in center
  
  int get currentIndex => _currentIndex;
  
  void setTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
  
  void goToChat() => setTab(0);
  void goToCommunity() => setTab(1);
  void goToToday() => setTab(2);
  void goToQuran() => setTab(3);
  void goToExplore() => setTab(4);
}

/// InheritedWidget to provide navigation controller to descendant widgets
class NavigationProvider extends InheritedNotifier<NavigationController> {
  const NavigationProvider({
    super.key,
    required NavigationController controller,
    required super.child,
  }) : super(notifier: controller);
  
  static NavigationController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<NavigationProvider>();
    return provider!.notifier!;
  }
  
  static NavigationController? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<NavigationProvider>();
    return provider?.notifier;
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  final NavigationController _navigationController = NavigationController();

  @override
  void initState() {
    super.initState();
    _navigationController.addListener(_onNavigationChanged);
  }

  @override
  void dispose() {
    _navigationController.removeListener(_onNavigationChanged);
    _navigationController.dispose();
    super.dispose();
  }

  void _onNavigationChanged() {
    setState(() {});
  }

  // List of screens for each tab (matching reference: Chat, Community, Today, Bible, Explore)
  List<Widget> get _screens => [
    const ChatScreen(),
    const PlaceholderScreen(title: 'Topluluk', icon: Icons.people_outline),
    const HomeScreen(), // "Today" / "Günün Yolculuğu"
    const QuranScreen(), // "Bible" equivalent -> Kuran
    const PlaceholderScreen(title: 'Keşfet', icon: Icons.explore_outlined),
  ];

  // Navigation items matching reference app
  final List<_NavItem> _navItems = [
    const _NavItem(
      label: 'Chat',
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
    ),
    const _NavItem(
      label: 'Topluluk',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
    ),
    const _NavItem(
      label: 'Bugün',
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      isCenter: true,
    ),
    const _NavItem(
      label: 'Kur\'an',
      svgPath: 'assets/icons/quran_icon.svg', // Custom Quran icon
    ),
    const _NavItem(
      label: 'Keşfet',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationProvider(
      controller: _navigationController,
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _navigationController.currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: LiquidGlassNavigationBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              return _buildNavItem(index, _navItems[index]);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item) {
    final isSelected = _navigationController.currentIndex == index;
    final iconColor = isSelected 
        ? GlobalAppStyle.accentColor
        : Colors.white.withOpacity(0.5);
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _navigationController.setTab(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated icon container - elevated when selected
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(0, isSelected ? -6 : 0, 0),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? GlobalAppStyle.accentColor.withOpacity(0.2)
                      : Colors.transparent,
                ),
                child: Center(
                  child: item.hasSvg
                      ? SvgPicture.asset(
                          item.svgPath!,
                          width: isSelected ? 26 : 24,
                          height: isSelected ? 26 : 24,
                          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                        )
                      : Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: iconColor,
                          size: isSelected ? 26 : 24,
                        ),
                ),
              ),
              // Animated text - moves down when selected
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(0, isSelected ? 4 : 0, 0),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 11 : 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected 
                        ? GlobalAppStyle.accentColor
                        : Colors.white.withOpacity(0.5),
                  ),
                  child: Text(item.label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData? icon;
  final IconData? activeIcon;
  final String? svgPath; // For custom SVG icons
  final bool isCenter;

  const _NavItem({
    required this.label,
    this.icon,
    this.activeIcon,
    this.svgPath,
    this.isCenter = false,
  });
  
  bool get hasSvg => svgPath != null;
}

// Placeholder screen for Community and Explore tabs
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    this.icon = Icons.construction_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            // Top gradient overlay with blur
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Top content (Header)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      // Profile Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              GlobalAppStyle.accentColor,
                              GlobalAppStyle.accentColor.withOpacity(0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: GlobalAppStyle.accentColor.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'K',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 14),
                      
                      // Title
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 64,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yakında eklenecek',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }
}
