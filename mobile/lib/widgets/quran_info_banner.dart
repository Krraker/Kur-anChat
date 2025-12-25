import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranInfoBanner extends StatefulWidget {
  final bool showOnInit;
  
  const QuranInfoBanner({
    super.key,
    this.showOnInit = false,
  });

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('quran_page_info_banner_dismissed') ?? false);
  }

  static Future<void> show(BuildContext context, {bool isAutoShow = false}) async {
    // Check if user has dismissed this banner before (only for auto-show)
    if (isAutoShow && !await shouldShow()) return;
    
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Bilgilendirme',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const QuranInfoBanner();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<QuranInfoBanner> createState() => _QuranInfoBannerState();
}

class _QuranInfoBannerState extends State<QuranInfoBanner> {
  bool _dontShowAgain = false;

  Future<void> _handleClose() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('quran_page_info_banner_dismissed', true);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                ),
                // SECONDARY LAYER - Lighter for further depth
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white.withOpacity(0.08), // Slightly lighter base
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 0.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.18), // LIGHTER gradient
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.white.withOpacity(0.9),
                          size: 28,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Title
                      Text(
                        'Bilgilendirme',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withOpacity(0.95),
                          letterSpacing: -0.5,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Info text - single justified paragraph
                      Text(
                        'Burada gördüğünüz Türkçe metin, Kur\'an-ı Kerim\'in resmi meali değildir. Bu içerik, Ayetleri anlamanızı kolaylaştırmak için hazırlanmış açıklayıcı bir özettir. Daha kapsamlı bir anlayış için lütfen güvenilir meal, islam Alimleri ve tefsirlere başvurun.',
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.white.withOpacity(0.85),
                          letterSpacing: -0.2,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // "Don't show again" checkbox
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _dontShowAgain = !_dontShowAgain;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.5,
                                  ),
                                  color: _dontShowAgain
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.transparent,
                                ),
                                child: _dontShowAgain
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Bir daha gösterme',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.75),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Close button
                      GestureDetector(
                        onTap: _handleClose,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.white.withOpacity(0.12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Anladım',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

