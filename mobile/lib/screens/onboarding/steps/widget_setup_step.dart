import 'package:flutter/material.dart';
import '../../../styles/styles.dart';

class WidgetSetupStep extends StatefulWidget {
  final String? language;
  
  const WidgetSetupStep({super.key, this.language});

  @override
  State<WidgetSetupStep> createState() => _WidgetSetupStepState();
}

class _WidgetSetupStepState extends State<WidgetSetupStep> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool get isEnglish => widget.language == 'en';

  List<Map<String, dynamic>> get _steps => isEnglish 
    ? [
        {
          'title': 'Make Your Home Screen a Place of Faith',
          'description': 'Touch and hold an empty area on your phone\'s home screen',
          'icon': Icons.touch_app,
        },
        {
          'title': 'Make Your Home Screen a Place of Faith',
          'description': 'Tap the "+" button in the upper-left corner',
          'icon': Icons.add_circle_outline,
        },
        {
          'title': 'Make Your Home Screen a Place of Faith',
          'description': 'Search for "Quran Chat" and select the widget',
          'icon': Icons.search,
        },
      ]
    : [
        {
          'title': 'Ana ekranınızı iman ile doldurun',
          'description': 'Telefonunuzun ana ekranında boş bir alana basılı tutun',
          'icon': Icons.touch_app,
        },
        {
          'title': 'Ana ekranınızı iman ile doldurun',
          'description': 'Sol üst köşedeki "+" butonuna dokunun',
          'icon': Icons.add_circle_outline,
        },
        {
          'title': 'Ana ekranınızı iman ile doldurun',
          'description': '"Kur\'an Chat" arayın ve widget\'ı seçin',
          'icon': Icons.search,
        },
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Title
          Text(
            _steps[_currentPage]['title'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _steps[_currentPage]['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Phone mockup
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              itemCount: _steps.length,
              itemBuilder: (context, index) {
                return _buildPhoneMockup(index);
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_steps.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive 
                      ? Colors.white 
                      : Colors.white.withOpacity(0.3),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup(int index) {
    return Center(
      child: Container(
        width: 260,
        height: 400,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Phone notch
            const SizedBox(height: 12),
            Container(
              width: 80,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Content based on step
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildStepContent(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(int index) {
    if (index == 0) {
      // Grid of app icons with touch indicator
      return Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: 12,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.touch_app,
            size: 48,
            color: Colors.grey.shade600,
          ),
        ],
      );
    } else if (index == 1) {
      // Show + button
      return Stack(
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: 12,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: i == 0 ? Icon(
                  Icons.remove_circle_outline,
                  color: Colors.grey.shade500,
                  size: 16,
                ) : null,
              );
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.touch_app,
                  size: 32,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Search for widget
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Kur\'an Chat',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: GlobalAppStyle.accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GÜNÜN AYETİ • 3 DK',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange.shade300,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      );
    }
  }
}
