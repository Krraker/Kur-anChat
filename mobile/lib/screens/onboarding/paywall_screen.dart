import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../styles/styles.dart';
import '../../services/subscription_service.dart';

// =============================================================================
// UNIFIED PAYWALL SCREEN
// =============================================================================

class PaywallScreen extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final String? language;
  final bool fromSettings;

  const PaywallScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.language,
    this.fromSettings = false,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  bool _wantsTrial = true;
  int _selectedPlanIndex = 0; // 0 = trial/monthly, 1 = yearly
  bool _isDisposed = false;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMessage;
  
  // Packages
  Package? _weeklyPackage;
  Package? _monthlyPackage;
  Package? _yearlyPackage;

  // Animation controllers
  late AnimationController _leftBigCloudController;
  late AnimationController _leftSmallCloudController;
  late AnimationController _rightCloudController;
  late AnimationController _doveController;
  late AnimationController _starsController;
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late AnimationController _sunPulseController;

  // Animations
  late Animation<double> _leftBigCloudSlide;
  late Animation<double> _leftSmallCloudSlide;
  late Animation<double> _rightCloudSlide;
  late Animation<double> _doveOpacity;
  late Animation<double> _doveSlide;
  late Animation<double> _starsOpacity;
  late Animation<double> _starsScale;
  late Animation<double> _float1;
  late Animation<double> _float2;
  late Animation<double> _float3;
  late Animation<double> _sunPulseAnimation;

  bool get isEnglish => widget.language == 'en';
  bool get _hasRealPackages => 
      _weeklyPackage != null || _monthlyPackage != null || _yearlyPackage != null;

  // Demo prices
  String get _weeklyPrice => isEnglish ? '\$2.99' : '₺29,99';
  String get _monthlyPrice => isEnglish ? '\$9.99' : '₺99,99';
  String get _yearlyPrice => isEnglish ? '\$59.99' : '₺999,99';
  int get _savingsPercent => 50; // 50% savings on yearly

  @override
  void initState() {
    super.initState();
    _loadOfferings();
    _initAnimations();
    _startEntryAnimations();
  }

  void _initAnimations() {
    _rightCloudController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );
    _rightCloudSlide = Tween<double>(begin: -350, end: 0).animate(
      CurvedAnimation(parent: _rightCloudController, curve: Curves.easeOutQuint),
    );

    _leftBigCloudController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _leftBigCloudSlide = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(parent: _leftBigCloudController, curve: Curves.easeOutQuint),
    );

    _leftSmallCloudController = AnimationController(
      duration: const Duration(milliseconds: 5500),
      vsync: this,
    );
    _leftSmallCloudSlide = Tween<double>(begin: -220, end: 0).animate(
      CurvedAnimation(parent: _leftSmallCloudController, curve: Curves.easeOutQuint),
    );

    _doveController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _doveOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _doveController, 
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _doveSlide = Tween<double>(begin: -80, end: 0).animate(
      CurvedAnimation(parent: _doveController, curve: Curves.easeOutQuart),
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _starsOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _starsController, curve: Curves.easeOut),
    );
    _starsScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _starsController, curve: Curves.easeOutQuart),
    );

    _floatController1 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _float1 = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController1, curve: Curves.easeInOut),
    );

    _floatController2 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _float2 = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController2, curve: Curves.easeInOut),
    );

    _floatController3 = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    );
    _float3 = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController3, curve: Curves.easeInOut),
    );

    _sunPulseController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _sunPulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _sunPulseController, curve: Curves.easeInOut),
    );
  }

  void _startEntryAnimations() async {
    if (_isDisposed) return;
    _rightCloudController.forward();
    
    // Dove comes early - right after first cloud
    await Future.delayed(const Duration(milliseconds: 400));
    if (_isDisposed || !mounted) return;
    _doveController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    if (_isDisposed || !mounted) return;
    _leftBigCloudController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_isDisposed || !mounted) return;
    _leftSmallCloudController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1200));
    if (_isDisposed || !mounted) return;
    _starsController.forward();
    
    await Future.delayed(const Duration(milliseconds: 2500));
    if (_isDisposed || !mounted) return;
    _startFloatingAnimations();
  }

  void _startFloatingAnimations() {
    if (_isDisposed || !mounted) return;
    _floatController1.repeat(reverse: true);
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_isDisposed || !mounted) return;
      _floatController2.repeat(reverse: true);
    });
    
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (_isDisposed || !mounted) return;
      _floatController3.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _leftBigCloudController.dispose();
    _leftSmallCloudController.dispose();
    _rightCloudController.dispose();
    _doveController.dispose();
    _starsController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    _floatController3.dispose();
    _sunPulseController.dispose();
    super.dispose();
  }

  Future<void> _loadOfferings() async {
    try {
      final subscriptionService = SubscriptionService();
      
      if (subscriptionService.packages.isEmpty) {
        await subscriptionService.loadOfferings();
      }
      
      if (mounted && !_isDisposed) {
        setState(() {
          _weeklyPackage = subscriptionService.weeklyPackage;
          _monthlyPackage = subscriptionService.monthlyPackage;
          _yearlyPackage = subscriptionService.yearlyPackage;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading offerings: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _purchaseSelectedPlan() async {
    if (!_hasRealPackages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish 
              ? 'Demo mode - RevenueCat not configured yet' 
              : 'Demo modu - RevenueCat henüz yapılandırılmadı'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && !_isDisposed) {
          widget.onContinue();
        }
      });
      return;
    }
    
    Package? package;
    if (_selectedPlanIndex == 0) {
      package = _monthlyPackage ?? _weeklyPackage;
    } else {
      package = _yearlyPackage;
    }
    
    if (package == null) {
      widget.onContinue();
      return;
    }

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      final result = await SubscriptionService().purchase(package);
      
      if (mounted && !_isDisposed) {
        setState(() => _isPurchasing = false);
        
        switch (result) {
          case PurchaseResultType.success:
            _showSuccessAndContinue();
            break;
          case PurchaseResultType.cancelled:
            break;
          case PurchaseResultType.failed:
            setState(() {
              _errorMessage = isEnglish
                  ? 'Purchase was not completed. Try again or skip.'
                  : 'Satın alma tamamlanmadı. Tekrar deneyin veya atlayın.';
            });
            break;
        }
      }
    } catch (e) {
      debugPrint('Purchase error: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isPurchasing = false;
          _errorMessage = isEnglish
              ? 'An error occurred. Please try again.'
              : 'Bir hata oluştu. Lütfen tekrar deneyin.';
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    
    try {
      final restored = await SubscriptionService().restore();
      
      if (mounted && !_isDisposed) {
        setState(() => _isPurchasing = false);
        
        if (restored) {
          _showSuccessAndContinue();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEnglish 
                  ? 'No previous purchases found' 
                  : 'Önceki satın alma bulunamadı'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _showSuccessAndContinue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEnglish 
            ? '🎉 Welcome to Premium!' 
            : '🎉 Premium\'a hoş geldiniz!'),
        backgroundColor: GlobalAppStyle.accentColor,
      ),
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        widget.onContinue();
      }
    });
  }

  String _getTrialEndDate() {
    final trialEnd = DateTime.now().add(const Duration(days: 7));
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    final monthsEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    if (isEnglish) {
      return '${monthsEn[trialEnd.month - 1]} ${trialEnd.day}, ${trialEnd.year}';
    }
    return '${trialEnd.day} ${months[trialEnd.month - 1]} ${trialEnd.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // SVG Background
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/PaywallAnimation/Background.svg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark overlay for better readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.7],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                      onPressed: widget.onSkip,
                      icon: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.6),
                        size: 24,
                      ),
                    ),
                  ),
                ),

                // Animated illustration header - reduced height
                _buildAnimatedHeader(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            isEnglish 
                                ? 'Never Miss a Moment of Faith'
                                : 'İman yolculuğunda hiçbir anı kaçırma',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'OggText',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Features list - Block 1
                        _buildFeatureItem(isEnglish
                            ? 'Home Screen Widget with Personalized Verses'
                            : 'Kişiselleştirilmiş Ayetlerle Ana Ekran Widget\'ı'),
                        const SizedBox(height: 8),
                        _buildFeatureItem(isEnglish
                            ? 'Bring the Quran to your Home Screen'
                            : 'Kur\'an\'ı Ana Ekranınıza Getirin'),
                        const SizedBox(height: 8),
                        _buildFeatureItem(isEnglish
                            ? 'Personalized Audio Daily Devotionals'
                            : 'Kişiselleştirilmiş Sesli Günlük Dualar'),

                        const SizedBox(height: 54), // INCREASED spacing between blocks

                        // Pricing containers - Block 2
                        // Trial toggle - compact
                        _buildTrialToggle(),

                        const SizedBox(height: 4),

                        // Package options
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: Colors.white54,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else ...[
                          // 7 days Free Trial option
                          _buildTrialPackageCard(),
                          
                          const SizedBox(height: 4),
                          
                          // Yearly option
                          _buildYearlyPackageCard(),
                        ],

                        const SizedBox(height: 4),

                        // Cancel anytime text
                        Center(
                          child: Text(
                            isEnglish
                                ? 'Cancel anytime before ${_getTrialEndDate()}.\nNo risks, no charges.'
                                : '${_getTrialEndDate()} tarihinden önce istediğiniz zaman iptal edin.\nRisk yok, ücret yok.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.5),
                              height: 1.3,
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [
                      // Error message
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.orange.shade300,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                      ],
                      
                      // Try for Free button - FIRST
                      _isPurchasing
                          ? const SizedBox(
                              height: 62,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: GlobalAppStyle.accentColor,
                                ),
                              ),
                            )
                          : _buildTryButton(),

                      const SizedBox(height: 14),
                      
                      // Terms links - BELOW the button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTermsLink(isEnglish ? 'Terms of use' : 'Kullanım Şartları'),
                          const SizedBox(width: 16),
                          _buildTermsLink(isEnglish ? 'Privacy policy' : 'Gizlilik Politikası'),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: _isPurchasing ? null : _restorePurchases,
                            child: Text(
                              isEnglish ? 'Restore' : 'Geri Yükle',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sun layers
          AnimatedBuilder(
            animation: _sunPulseAnimation,
            builder: (context, child) {
              return Positioned(
                right: -80,
                top: -150,
                child: Transform.scale(
                  scale: _sunPulseAnimation.value,
                  child: SvgPicture.asset(
                    'assets/PaywallAnimation/sun_outer.svg',
                    width: 350,
                    height: 350,
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _sunPulseAnimation,
            builder: (context, child) {
              return Positioned(
                right: -40,
                top: -100,
                child: Transform.scale(
                  scale: _sunPulseAnimation.value,
                  child: SvgPicture.asset(
                    'assets/PaywallAnimation/sun_middle.svg',
                    width: 280,
                    height: 180,
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: _sunPulseAnimation,
            builder: (context, child) {
              return Positioned(
                right: 10,
                top: -50,
                child: Transform.scale(
                  scale: _sunPulseAnimation.value,
                  child: SvgPicture.asset(
                    'assets/PaywallAnimation/sun_core.svg',
                    width: 180,
                    height: 120,
                  ),
                ),
              );
            },
          ),

          // Clouds
          AnimatedBuilder(
            animation: Listenable.merge([_leftBigCloudSlide, _float1]),
            builder: (context, child) {
              return Positioned(
                left: -80 + _leftBigCloudSlide.value + _float1.value,
                top: -20,
                child: SvgPicture.asset(
                  'assets/PaywallAnimation/cloud_LeftBig.svg',
                  width: 260,
                  height: 160,
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: Listenable.merge([_rightCloudSlide, _float2]),
            builder: (context, child) {
              return Positioned(
                right: -50 + _rightCloudSlide.value + _float2.value,
                top: 60,
                child: SvgPicture.asset(
                  'assets/PaywallAnimation/cloud_right.svg',
                  width: 200,
                  height: 120,
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: Listenable.merge([_leftSmallCloudSlide, _float3]),
            builder: (context, child) {
              return Positioned(
                left: -40 + _leftSmallCloudSlide.value + _float3.value,
                top: 100,
                child: SvgPicture.asset(
                  'assets/PaywallAnimation/cloud_LeftSmall.svg',
                  width: 130,
                  height: 80,
                ),
              );
            },
          ),

          // Stars
          AnimatedBuilder(
            animation: Listenable.merge([_starsOpacity, _starsScale, _float3]),
            builder: (context, child) {
              return Positioned(
                left: screenWidth * 0.15 + (_float3.value * 0.5),
                top: -10,
                child: Opacity(
                  opacity: _starsOpacity.value,
                  child: Transform.scale(
                    scale: _starsScale.value,
                    child: SvgPicture.asset(
                      'assets/PaywallAnimation/star.svg',
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              );
            },
          ),

          AnimatedBuilder(
            animation: Listenable.merge([_starsOpacity, _starsScale, _float2]),
            builder: (context, child) {
              return Positioned(
                right: 60 + (_float2.value * 0.4),
                top: -25,
                child: Opacity(
                  opacity: _starsOpacity.value * 0.8,
                  child: Transform.scale(
                    scale: _starsScale.value,
                    child: SvgPicture.asset(
                      'assets/PaywallAnimation/star.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              );
            },
          ),

          // Dove
          AnimatedBuilder(
            animation: Listenable.merge([_doveOpacity, _doveSlide, _float1]),
            builder: (context, child) {
              return Positioned(
                left: _doveSlide.value + (_float1.value * 0.8),
                right: 0,
                top: 30,
                child: Center(
                  child: Opacity(
                    opacity: _doveOpacity.value,
                    child: SvgPicture.asset(
                      'assets/PaywallAnimation/dove.svg',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: GlobalAppStyle.accentColor.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.check,
            color: GlobalAppStyle.accentColor,
            size: 13,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrialToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isEnglish
                  ? 'I want to try the app for free'
                  : 'Uygulamayı ücretsiz denemek istiyorum',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _wantsTrial,
              onChanged: (value) {
                setState(() {
                  _wantsTrial = value;
                  if (value) {
                    _selectedPlanIndex = 0;
                  }
                });
              },
              activeColor: GlobalAppStyle.accentColor,
              activeTrackColor: GlobalAppStyle.accentColor.withOpacity(0.4),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrialPackageCard() {
    final isSelected = _selectedPlanIndex == 0;
    final monthlyPrice = _hasRealPackages 
        ? _monthlyPackage?.storeProduct.priceString ?? _monthlyPrice
        : _monthlyPrice;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? '7 days Free Trial' : '7 Gün Ücretsiz Deneme',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              isEnglish 
                  ? 'Then $monthlyPrice per month. No payment now'
                  : 'Sonra ayda $monthlyPrice. Şimdi ödeme yok',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyPackageCard() {
    final isSelected = _selectedPlanIndex == 1;
    final yearlyPrice = _hasRealPackages 
        ? _yearlyPackage?.storeProduct.priceString ?? _yearlyPrice
        : _yearlyPrice;
    
    final savings = _hasRealPackages 
        ? SubscriptionService().yearlySavingsPercent ?? _savingsPercent
        : _savingsPercent;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = 1),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? 'Yearly Access' : 'Yıllık Erişim',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isEnglish 
                        ? 'billed yearly at $yearlyPrice'
                        : 'yıllık $yearlyPrice',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Savings badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935), // Red badge
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isEnglish ? 'SAVE -$savings%' : '%$savings TASARRUF',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTryButton() {
    return GestureDetector(
      onTap: _purchaseSelectedPlan,
      child: Container(
        width: double.infinity,
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Less rounded corners
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _wantsTrial && _selectedPlanIndex == 0
                  ? (isEnglish ? 'Try for Free' : 'Ücretsiz Dene')
                  : (isEnglish ? 'Subscribe Now' : 'Şimdi Abone Ol'),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsLink(String text) {
    return GestureDetector(
      onTap: () {
        // TODO: Open terms URL
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }
}

// =============================================================================
// PAYWALL ROUTE HELPER
// =============================================================================

Future<bool> showPaywall(
  BuildContext context, {
  String? language,
}) async {
  bool purchased = false;
  
  await Navigator.of(context).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PaywallScreen(
        language: language,
        fromSettings: true,
        onContinue: () {
          purchased = true;
          Navigator.of(context).pop();
        },
        onSkip: () {
          Navigator.of(context).pop();
        },
      ),
    ),
  );
  
  return purchased;
}
