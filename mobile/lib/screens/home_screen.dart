import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/home/quick_actions_section.dart';
import '../widgets/home/topics_carousel.dart';
import '../widgets/home/recent_questions_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/GettyImages-606920431.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark overlay to ensure text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.4, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // Scrollable content area
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 70,
              bottom: 160,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SizedBox(height: 20),
                
                // Quick Actions (2 cards: Dualar, Sure/Cüz)
                QuickActionsSection(),
                
                SizedBox(height: 180),
                
                // Topics carousel
                TopicsCarousel(),
                
                SizedBox(height: 20),
                
                // Recent questions
                RecentQuestionsSection(),
                
                SizedBox(height: 24),
              ],
            ),
          ),
          
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
                    height: MediaQuery.of(context).padding.top + 90,
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
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Top content (AppBar) on top of blur
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                left: 16,
                right: 16,
              ),
              height: MediaQuery.of(context).padding.top + 70,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ayet Rehberi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Kuran ayetlerine dayalı rehber',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE8F5E9),
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Navigate to settings screen when implemented
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
