import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/app_gradient_background.dart';
import '../../widgets/onboarding/continue_button.dart';
import '../../styles/styles.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final String? language;

  const PaywallScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.language,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _wantsTrial = true;
  int _selectedPlan = 0; // 0 = weekly, 1 = yearly
  
  bool get isEnglish => widget.language == 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: widget.onSkip,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // App icon with Allah SVG
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: GlobalAppStyle.accentColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: GlobalAppStyle.accentColor.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/allah_icon.svg',
                            width: 56,
                            height: 56,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        isEnglish ? 'Never Miss a Moment of Faith' : 'İman Anlarını Kaçırmayın',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Features
                      _buildFeatureItem(isEnglish ? 'Personalized daily verses' : 'Kişiselleştirilmiş günlük ayetler'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(isEnglish ? 'Unlimited chat and questions' : 'Sınırsız sohbet ve soru sorma'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(isEnglish ? 'Audio tafsir and prayers' : 'Sesli tefsir ve dua'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(isEnglish ? 'Home screen widget' : 'Ana ekran widget\'ı'),
                      
                      const SizedBox(height: 16),
                      
                      // Trial toggle
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                isEnglish ? 'I want to try the app for free' : 'Uygulamayı ücretsiz denemek istiyorum',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.85,
                              child: Switch(
                                value: _wantsTrial,
                                onChanged: (value) {
                                  setState(() => _wantsTrial = value);
                                },
                                activeColor: GlobalAppStyle.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Pricing options
                      _buildPricingOption(
                        title: isEnglish ? '7 Days Free Trial' : '7 Gün Ücretsiz Deneme',
                        subtitle: isEnglish ? 'Then \$4.99/month. No payment now.' : 'Sonra aylık ₺49,99. Şimdi ödeme yok.',
                        isSelected: _selectedPlan == 0,
                        onTap: () => setState(() => _selectedPlan = 0),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      _buildPricingOption(
                        title: isEnglish ? 'Yearly Access' : 'Yıllık Erişim',
                        subtitle: isEnglish ? 'Billed yearly at \$29.99' : 'Yıllık ₺299,99',
                        isSelected: _selectedPlan == 1,
                        badge: isEnglish ? 'SAVE 50%' : '%50 TASARRUF',
                        onTap: () => setState(() => _selectedPlan = 1),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // Cancellation note
                      Text(
                        isEnglish 
                            ? 'Cancel anytime before Dec 15, 2025. No risks, no charges.'
                            : '15 Aralık 2025\'e kadar istediğiniz zaman iptal edin. Risk yok, ücret yok.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              
              // Bottom buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ContinueButton(
                      text: isEnglish ? 'Try for Free' : 'Ücretsiz Dene',
                      onPressed: widget.onContinue,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Terms
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTermsLink(isEnglish ? 'Terms of Use' : 'Kullanım Şartları'),
                        const SizedBox(width: 16),
                        _buildTermsLink(isEnglish ? 'Privacy Policy' : 'Gizlilik Politikası'),
                        const SizedBox(width: 16),
                        _buildTermsLink(isEnglish ? 'Restore' : 'Geri Yükle'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: GlobalAppStyle.accentColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: GlobalAppStyle.accentColor,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(isSelected ? 1 : 0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsLink(String text) {
    return GestureDetector(
      onTap: () {
        // TODO: Open terms
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.5),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
