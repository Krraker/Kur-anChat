import 'package:flutter/material.dart';
import '../../widgets/app_gradient_background.dart';
import '../../widgets/onboarding/continue_button.dart';
import '../../styles/styles.dart';

class PaywallScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PaywallScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _wantsTrial = true;
  int _selectedPlan = 0; // 0 = weekly, 1 = yearly

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
                      // Illustration
                      SizedBox(
                        height: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Clouds
                            Positioned(
                              left: 20,
                              top: 30,
                              child: _buildCloud(60),
                            ),
                            Positioned(
                              right: 30,
                              top: 60,
                              child: _buildCloud(50),
                            ),
                            Positioned(
                              left: 60,
                              bottom: 40,
                              child: _buildCloud(40),
                            ),
                            // Moon/Sun with dove
                            Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      GlobalAppStyle.accentColor.withOpacity(0.3),
                                      GlobalAppStyle.accentColor.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.auto_awesome,
                                    size: 48,
                                    color: GlobalAppStyle.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Title
                      const Text(
                        'İman Anlarını Kaçırmayın',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Features
                      _buildFeatureItem('Kişiselleştirilmiş günlük ayetler'),
                      const SizedBox(height: 12),
                      _buildFeatureItem('Sınırsız sohbet ve soru sorma'),
                      const SizedBox(height: 12),
                      _buildFeatureItem('Sesli tefsir ve dua'),
                      const SizedBox(height: 12),
                      _buildFeatureItem('Ana ekran widget\'ı'),
                      
                      const SizedBox(height: 24),
                      
                      // Trial toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Uygulamayı ücretsiz denemek istiyorum',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            Switch(
                              value: _wantsTrial,
                              onChanged: (value) {
                                setState(() => _wantsTrial = value);
                              },
                              activeColor: GlobalAppStyle.accentColor,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Pricing options
                      _buildPricingOption(
                        title: '7 Gün Ücretsiz Deneme',
                        subtitle: 'Sonra aylık ₺49,99. Şimdi ödeme yok.',
                        isSelected: _selectedPlan == 0,
                        onTap: () => setState(() => _selectedPlan = 0),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildPricingOption(
                        title: 'Yıllık Erişim',
                        subtitle: 'Yıllık ₺299,99',
                        isSelected: _selectedPlan == 1,
                        badge: '%50 TASARRUF',
                        onTap: () => setState(() => _selectedPlan = 1),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Cancellation note
                      Text(
                        '15 Aralık 2025\'e kadar istediğiniz zaman iptal edin.\nRisk yok, ücret yok.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
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
                      text: 'Ücretsiz Dene',
                      onPressed: widget.onContinue,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Terms
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTermsLink('Kullanım Şartları'),
                        const SizedBox(width: 16),
                        _buildTermsLink('Gizlilik Politikası'),
                        const SizedBox(width: 16),
                        _buildTermsLink('Geri Yükle'),
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

  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
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
