import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../widgets/onboarding/continue_button.dart';
import '../../styles/styles.dart';
import '../../services/subscription_service.dart';

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

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  bool _wantsTrial = true;
  int _selectedPlan = 0;
  bool _isDisposed = false; // Track disposal state for async operations
  bool _isLoading = true;
  bool _isPurchasing = false;
  List<Package> _packages = [];
  String? _errorMessage;

  // Entry animation controllers (play once)
  late AnimationController _leftBigCloudController;
  late AnimationController _leftSmallCloudController;
  late AnimationController _rightCloudController;
  late AnimationController _doveController;
  late AnimationController _starsController;
  
  // Ongoing subtle horizontal floating (after intro)
  late AnimationController _floatController1;
  late AnimationController _floatController2;
  late AnimationController _floatController3;
  late AnimationController _sunPulseController;

  // Entry animations
  late Animation<double> _leftBigCloudSlide;
  late Animation<double> _leftSmallCloudSlide;
  late Animation<double> _rightCloudSlide;
  late Animation<double> _doveOpacity;
  late Animation<double> _doveSlide;
  late Animation<double> _starsOpacity;
  late Animation<double> _starsScale;
  
  // Ongoing horizontal float animations (very slow, left-right)
  late Animation<double> _float1;
  late Animation<double> _float2;
  late Animation<double> _float3;
  late Animation<double> _sunPulseAnimation;

  bool get isEnglish => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    
    // Load subscription packages from RevenueCat
    _loadOfferings();

    // === ENTRY ANIMATIONS (very slow, elegant) ===
    
    // Right cloud - slides from RIGHT to LEFT (FIRST to appear)
    // Negative value = off-screen to the right
    _rightCloudController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );
    _rightCloudSlide = Tween<double>(begin: -350, end: 0).animate(
      CurvedAnimation(parent: _rightCloudController, curve: Curves.easeOutQuint),
    );

    // Left big cloud - slides from left (second)
    _leftBigCloudController = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );
    _leftBigCloudSlide = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(parent: _leftBigCloudController, curve: Curves.easeOutQuint),
    );

    // Left small cloud - slides from left (third)
    _leftSmallCloudController = AnimationController(
      duration: const Duration(milliseconds: 5500),
      vsync: this,
    );
    _leftSmallCloudSlide = Tween<double>(begin: -220, end: 0).animate(
      CurvedAnimation(parent: _leftSmallCloudController, curve: Curves.easeOutQuint),
    );

    // Dove - fades in + slides from left (very elegant)
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

    // Stars - fade in + scale (elegant)
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

    // === ONGOING SUBTLE HORIZONTAL FLOATING (very slow, oscillating left/right) ===
    
    // Float 1 - for left big cloud and dove (8 seconds cycle)
    _floatController1 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _float1 = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController1, curve: Curves.easeInOut),
    );

    // Float 2 - for right cloud (10 seconds cycle, different phase)
    _floatController2 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _float2 = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController2, curve: Curves.easeInOut),
    );

    // Float 3 - for left small cloud and stars (7 seconds cycle)
    _floatController3 = AnimationController(
      duration: const Duration(seconds: 7),
      vsync: this,
    );
    _float3 = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController3, curve: Curves.easeInOut),
    );

    // Sun very gentle pulse
    _sunPulseController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    _sunPulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _sunPulseController, curve: Curves.easeInOut),
    );

    // Start entry animation sequence
    _startEntryAnimations();
  }

  void _startEntryAnimations() async {
    // Right cloud comes FIRST from the right
    if (_isDisposed) return;
    _rightCloudController.forward();
    
    // Left big cloud comes second
    await Future.delayed(const Duration(milliseconds: 800));
    if (_isDisposed || !mounted) return;
    _leftBigCloudController.forward();
    
    // Left small cloud comes third
    await Future.delayed(const Duration(milliseconds: 1200));
    if (_isDisposed || !mounted) return;
    _leftSmallCloudController.forward();
    
    // Dove appears after clouds are moving
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_isDisposed || !mounted) return;
    _doveController.forward();
    
    // Stars appear last
    await Future.delayed(const Duration(milliseconds: 1800));
    if (_isDisposed || !mounted) return;
    _starsController.forward();
    
    // Start the subtle horizontal floating after intro completes
    await Future.delayed(const Duration(milliseconds: 3000));
    if (_isDisposed || !mounted) return;
    _startFloatingAnimations();
  }

  void _startFloatingAnimations() {
    // Start floating with different phases for organic feel
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
    _isDisposed = true; // Mark as disposed before disposing controllers
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

  /// Load subscription packages from RevenueCat
  Future<void> _loadOfferings() async {
    try {
      final subscriptionService = SubscriptionService();
      
      // Load offerings if not already loaded
      if (subscriptionService.packages.isEmpty) {
        await subscriptionService.loadOfferings();
      }
      
      if (mounted && !_isDisposed) {
        setState(() {
          _packages = subscriptionService.packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading offerings: $e');
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
          _errorMessage = isEnglish 
              ? 'Unable to load subscription options' 
              : 'Abonelik seçenekleri yüklenemedi';
        });
      }
    }
  }

  /// Handle subscription purchase
  Future<void> _purchaseSelectedPlan() async {
    // If no packages loaded, allow free trial (skip)
    if (_packages.isEmpty) {
      widget.onContinue();
      return;
    }

    // Get the selected package
    Package? selectedPackage;
    if (_selectedPlan < _packages.length) {
      selectedPackage = _packages[_selectedPlan];
    } else if (_packages.isNotEmpty) {
      selectedPackage = _packages.first;
    }

    if (selectedPackage == null) {
      widget.onContinue();
      return;
    }

    setState(() {
      _isPurchasing = true;
      _errorMessage = null;
    });

    try {
      final result = await SubscriptionService().purchase(selectedPackage);
      
      if (mounted && !_isDisposed) {
        setState(() => _isPurchasing = false);
        
        switch (result) {
          case PurchaseResultType.success:
            _showSuccessAndContinue();
            break;
          case PurchaseResultType.cancelled:
            // User cancelled - don't show error, just let them try again
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

  /// Restore previous purchases
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
    
    // Small delay to show the success message
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        widget.onContinue();
      }
    });
  }

  /// Get display price for a package
  String _getPackagePrice(int index) {
    if (index < _packages.length) {
      return _packages[index].storeProduct.priceString;
    }
    // Fallback prices if packages not loaded
    // USD: Weekly $1.99, Monthly $7.99, Yearly $29.99
    // TRY: Weekly ₺29,99, Monthly ₺99,99, Yearly ₺699,99
    switch (index) {
      case 0: // Weekly
        return isEnglish ? '\$1.99/wk' : '₺29,99/hafta';
      case 1: // Monthly
        return isEnglish ? '\$7.99/mo' : '₺99,99/ay';
      case 2: // Yearly
        return isEnglish ? '\$29.99/yr' : '₺699,99/yıl';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // SVG Background - covers entire screen
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/PaywallAnimation/Background.svg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // Close button - minimal space
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
                      size: 22,
                    ),
                  ),
                ),
              ),

              // Animated illustration header - compact height, big elements
              _buildAnimatedHeader(),

              // Content - compact, shifted up
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Title - SVG text - BIGGER
                      SvgPicture.asset(
                        'assets/PaywallAnimation/NeverMissaMomentofFaith.svg',
                        width: MediaQuery.of(context).size.width * 0.95,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Features - compact
                      _buildFeatureItem(isEnglish
                          ? 'Personalized daily verses'
                          : 'Kişiselleştirilmiş günlük ayetler'),
                      const SizedBox(height: 5),
                      _buildFeatureItem(isEnglish
                          ? 'Unlimited chat and questions'
                          : 'Sınırsız sohbet ve soru sorma'),
                      const SizedBox(height: 5),
                      _buildFeatureItem(isEnglish
                          ? 'Audio tafsir and prayers'
                          : 'Sesli tefsir ve dua'),
                      const SizedBox(height: 5),
                      _buildFeatureItem(isEnglish
                          ? 'Home screen widget'
                          : 'Ana ekran widget\'ı'),

                      const SizedBox(height: 8),

                      // Trial toggle
                      _buildTrialToggle(),

                      const SizedBox(height: 6),

                      // Pricing options - show loading or real packages
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(
                            color: Colors.white54,
                            strokeWidth: 2,
                          ),
                        )
                      else ...[
                        _buildPricingOption(
                          title: isEnglish
                              ? '7 Days Free Trial'
                              : '7 Gün Ücretsiz Deneme',
                          subtitle: isEnglish
                              ? 'Then ${_getPackagePrice(0)}. No payment now.'
                              : 'Sonra ${_getPackagePrice(0)}. Şimdi ödeme yok.',
                          isSelected: _selectedPlan == 0,
                          onTap: () => setState(() => _selectedPlan = 0),
                        ),

                        const SizedBox(height: 5),

                        _buildPricingOption(
                          title: isEnglish ? 'Yearly Access' : 'Yıllık Erişim',
                          subtitle: isEnglish
                              ? 'Billed yearly at ${_getPackagePrice(1)}'
                              : 'Yıllık ${_getPackagePrice(1)}',
                          isSelected: _selectedPlan == 1,
                          badge: isEnglish ? 'SAVE 50%' : '%50 TASARRUF',
                          onTap: () => setState(() => _selectedPlan = 1),
                        ),
                      ],

                      const SizedBox(height: 5),

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
                    ],
                  ),
                ),
              ),

              // Bottom buttons - compact padding
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Column(
                  children: [
                    // Error message if any
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.orange.shade300,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                    
                    // Purchase button with loading state
                    _isPurchasing
                        ? const SizedBox(
                            height: 56,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: GlobalAppStyle.accentColor,
                              ),
                            ),
                          )
                        : ContinueButton(
                            text: _wantsTrial
                                ? (isEnglish ? 'Try for Free' : 'Ücretsiz Dene')
                                : (isEnglish ? 'Subscribe Now' : 'Şimdi Abone Ol'),
                            onPressed: _purchaseSelectedPlan,
                          ),

                    const SizedBox(height: 10),

                    // Terms
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTermsLink(
                            isEnglish ? 'Terms of Use' : 'Kullanım Şartları'),
                        const SizedBox(width: 16),
                        _buildTermsLink(isEnglish
                            ? 'Privacy Policy'
                            : 'Gizlilik Politikası'),
                        const SizedBox(width: 16),
                        _buildRestoreLink(),
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
    // Get screen width for proportional positioning
    final screenWidth = MediaQuery.of(context).size.width;
    
    return SizedBox(
      height: 160, // Reduced height - elements overflow upward
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // === SUN LAYERS (upper right - subtle pulse animation) ===
          // Sun outer glow - BIGGER
          AnimatedBuilder(
            animation: _sunPulseAnimation,
            builder: (context, child) {
              return Positioned(
                right: -120,
                top: -200,
                child: Transform.scale(
                  scale: _sunPulseAnimation.value,
                  child: SvgPicture.asset(
                    'assets/PaywallAnimation/sun_outer.svg',
                    width: 450,
                    height: 470,
                  ),
                ),
              );
            },
          ),

          // Sun middle ring - BIGGER
          AnimatedBuilder(
            animation: _sunPulseAnimation,
            builder: (context, child) {
              return Positioned(
                right: -60,
                top: -130,
                child: Transform.scale(
                  scale: _sunPulseAnimation.value,
                  child: SvgPicture.asset(
                    'assets/PaywallAnimation/sun_middle.svg',
                    width: 340,
                    height: 200,
                  ),
                ),
              );
            },
          ),

          // Sun core - BIGGER
          AnimatedBuilder(
            animation: _sunPulseAnimation,
            builder: (context, child) {
              return Positioned(
                right: -10,
                top: -80,
                child: Transform.scale(
                  scale: _sunPulseAnimation.value,
                  child: SvgPicture.asset(
                    'assets/PaywallAnimation/sun_core.svg',
                    width: 230,
                    height: 140,
                  ),
                ),
              );
            },
          ),

          // === CLOUDS (slide in from edges, then float HORIZONTALLY) ===
          // Left big cloud - BIGGER, slides from left
          AnimatedBuilder(
            animation: Listenable.merge([_leftBigCloudSlide, _float1]),
            builder: (context, child) {
              return Positioned(
                left: -100 + _leftBigCloudSlide.value + _float1.value,
                top: -40,
                child: SvgPicture.asset(
                  'assets/PaywallAnimation/cloud_LeftBig.svg',
                  width: 320,
                  height: 195,
                ),
              );
            },
          ),

          // Right cloud - BIGGER, slides from right
          AnimatedBuilder(
            animation: Listenable.merge([_rightCloudSlide, _float2]),
            builder: (context, child) {
              return Positioned(
                right: -70 + _rightCloudSlide.value + _float2.value,
                top: 40,
                child: SvgPicture.asset(
                  'assets/PaywallAnimation/cloud_right.svg',
                  width: 250,
                  height: 150,
                ),
              );
            },
          ),

          // Left small cloud - BIGGER, slides from left
          AnimatedBuilder(
            animation: Listenable.merge([_leftSmallCloudSlide, _float3]),
            builder: (context, child) {
              return Positioned(
                left: -60 + _leftSmallCloudSlide.value + _float3.value,
                top: 110,
                child: SvgPicture.asset(
                  'assets/PaywallAnimation/cloud_LeftSmall.svg',
                  width: 160,
                  height: 100,
                ),
              );
            },
          ),

          // === STARS (fade in + scale, then float HORIZONTALLY) ===
          // Star near dove (top left of center) - BIGGER
          AnimatedBuilder(
            animation: Listenable.merge([_starsOpacity, _starsScale, _float3]),
            builder: (context, child) {
              return Positioned(
                left: screenWidth * 0.20 + (_float3.value * 0.5),
                top: -20,
                child: Opacity(
                  opacity: _starsOpacity.value,
                  child: Transform.scale(
                    scale: _starsScale.value,
                    child: SvgPicture.asset(
                      'assets/PaywallAnimation/star.svg',
                      width: 36,
                      height: 36,
                    ),
                  ),
                ),
              );
            },
          ),

          // Star upper right (small) - BIGGER
          AnimatedBuilder(
            animation: Listenable.merge([_starsOpacity, _starsScale, _float2]),
            builder: (context, child) {
              return Positioned(
                right: 50 + (_float2.value * 0.4),
                top: -35,
                child: Opacity(
                  opacity: _starsOpacity.value * 0.8,
                  child: Transform.scale(
                    scale: _starsScale.value,
                    child: SvgPicture.asset(
                      'assets/PaywallAnimation/star.svg',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
              );
            },
          ),

          // Star right side (medium) - BIGGER
          AnimatedBuilder(
            animation: Listenable.merge([_starsOpacity, _starsScale, _float1]),
            builder: (context, child) {
              return Positioned(
                right: 25 + (_float1.value * 0.6),
                top: 5,
                child: Opacity(
                  opacity: _starsOpacity.value,
                  child: Transform.scale(
                    scale: _starsScale.value,
                    child: SvgPicture.asset(
                      'assets/PaywallAnimation/star.svg',
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
              );
            },
          ),

          // === DOVE (fade in + slide from left, then float HORIZONTALLY) ===
          AnimatedBuilder(
            animation: Listenable.merge([_doveOpacity, _doveSlide, _float1]),
            builder: (context, child) {
              return Positioned(
                left: _doveSlide.value + (_float1.value * 0.8),
                right: 10,
                top: 10,
                child: Center(
                  child: Opacity(
                    opacity: _doveOpacity.value,
                    child: SvgPicture.asset(
                      'assets/PaywallAnimation/dove.svg',
                      width: 115,
                      height: 115,
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

  Widget _buildTrialToggle() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.08),
                      ]
                    : [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.04),
                      ],
              ),
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
        ),
      ),
    );
  }

  Widget _buildTermsLink(String text) {
    return GestureDetector(
      onTap: () {
        // TODO: Open terms URL in browser
        // You can use url_launcher package here
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

  Widget _buildRestoreLink() {
    return GestureDetector(
      onTap: _isPurchasing ? null : _restorePurchases,
      child: Text(
        isEnglish ? 'Restore' : 'Geri Yükle',
        style: TextStyle(
          fontSize: 12,
          color: _isPurchasing 
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.5),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
