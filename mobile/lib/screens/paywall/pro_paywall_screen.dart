import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/subscription_service.dart';

// =============================================================================
// PRO PAYWALL SCREEN
// =============================================================================
// 
// A clean, production-ready paywall for Kur'anChat Pro subscriptions.
// 
// Features:
// - Displays weekly, monthly, yearly packages
// - Highlights best value (yearly)
// - Shows savings percentage
// - Purchase and restore buttons
// - Loading states and error handling
// - Turkish localization
//
// Usage:
// ```dart
// Navigator.push(context, MaterialPageRoute(
//   builder: (_) => ProPaywallScreen(
//     onPurchaseSuccess: () => Navigator.pop(context),
//   ),
// ));
// ```
// =============================================================================

class ProPaywallScreen extends StatefulWidget {
  /// Called when purchase is successful
  final VoidCallback? onPurchaseSuccess;
  
  /// Called when user dismisses without purchasing
  final VoidCallback? onDismiss;
  
  /// Whether to show close button (default: true)
  final bool showCloseButton;
  
  /// Use Turkish language (default: true)
  final bool turkish;

  const ProPaywallScreen({
    super.key,
    this.onPurchaseSuccess,
    this.onDismiss,
    this.showCloseButton = true,
    this.turkish = true,
  });

  @override
  State<ProPaywallScreen> createState() => _ProPaywallScreenState();
}

class _ProPaywallScreenState extends State<ProPaywallScreen> {
  final _subscriptionService = SubscriptionService();
  
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;
  Package? _selectedPackage;
  
  // Packages
  Package? _weeklyPackage;
  Package? _monthlyPackage;
  Package? _yearlyPackage;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load offerings if not already loaded
      if (_subscriptionService.packages.isEmpty) {
        await _subscriptionService.loadOfferings();
      }
      
      // Get packages
      _weeklyPackage = _subscriptionService.weeklyPackage;
      _monthlyPackage = _subscriptionService.monthlyPackage;
      _yearlyPackage = _subscriptionService.yearlyPackage;
      
      // Default selection: yearly (best value)
      _selectedPackage = _yearlyPackage ?? _monthlyPackage ?? _weeklyPackage;
      
      setState(() => _isLoading = false);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = widget.turkish 
            ? 'Paketler yüklenemedi. Lütfen tekrar deneyin.'
            : 'Failed to load packages. Please try again.';
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null || _isPurchasing) return;
    
    setState(() {
      _isPurchasing = true;
      _error = null;
    });

    final result = await _subscriptionService.purchase(_selectedPackage!);
    
    if (!mounted) return;
    
    setState(() => _isPurchasing = false);
    
    switch (result) {
      case PurchaseResultType.success:
        _showSuccessMessage();
        widget.onPurchaseSuccess?.call();
        break;
      case PurchaseResultType.cancelled:
        // User cancelled - no action needed
        break;
      case PurchaseResultType.failed:
        setState(() {
          _error = _subscriptionService.error ?? 
              (widget.turkish 
                  ? 'Satın alma başarısız. Lütfen tekrar deneyin.'
                  : 'Purchase failed. Please try again.');
        });
        break;
    }
  }

  Future<void> _restore() async {
    if (_isPurchasing) return;
    
    setState(() {
      _isPurchasing = true;
      _error = null;
    });

    final restored = await _subscriptionService.restore();
    
    if (!mounted) return;
    
    setState(() => _isPurchasing = false);
    
    if (restored) {
      _showSuccessMessage();
      widget.onPurchaseSuccess?.call();
    } else {
      _showMessage(
        widget.turkish 
            ? 'Aktif abonelik bulunamadı'
            : 'No active subscription found',
        isError: false,
      );
    }
  }

  void _showSuccessMessage() {
    _showMessage(
      widget.turkish 
          ? '🎉 Pro\'ya hoş geldiniz!'
          : '🎉 Welcome to Pro!',
      isError: false,
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF00A86B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            _buildHeader(),
            
            // Content
            Expanded(
              child: _isLoading 
                  ? _buildLoadingState()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          if (widget.showCloseButton)
            IconButton(
              onPressed: () {
                widget.onDismiss?.call();
                Navigator.of(context).maybePop();
              },
              icon: Icon(
                Icons.close,
                color: Colors.white.withAlpha(153),
              ),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          // Restore button
          TextButton(
            onPressed: _isPurchasing ? null : _restore,
            child: Text(
              widget.turkish ? 'Geri Yükle' : 'Restore',
              style: TextStyle(
                color: Colors.white.withAlpha(179),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF00A86B),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Pro icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00A86B), Color(0xFF00D084)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00A86B).withAlpha(77),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            widget.turkish ? 'Kur\'anChat Pro' : 'Kur\'anChat Pro',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
          Text(
            widget.turkish 
                ? 'Sınırsız erişim ile manevi yolculuğunuzu derinleştirin'
                : 'Deepen your spiritual journey with unlimited access',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(179),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Features
          _buildFeaturesList(),
          
          const SizedBox(height: 32),
          
          // Package options
          _buildPackageOptions(),
          
          const SizedBox(height: 24),
          
          // Error message
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Purchase button
          _buildPurchaseButton(),
          
          const SizedBox(height: 16),
          
          // Terms
          _buildTermsText(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = widget.turkish 
        ? [
            'Sınırsız AI sohbet',
            'Günlük kişisel ayetler',
            'Sesli tefsir ve dualar',
            'Tüm surelere erişim',
            'Reklamsız deneyim',
          ]
        : [
            'Unlimited AI chat',
            'Daily personalized verses',
            'Audio tafsir and prayers',
            'Access to all surahs',
            'Ad-free experience',
          ];
    
    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF00A86B).withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF00A86B),
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildPackageOptions() {
    return Column(
      children: [
        // Yearly - Best Value
        if (_yearlyPackage != null)
          _buildPackageCard(
            package: _yearlyPackage!,
            title: widget.turkish ? 'Yıllık' : 'Yearly',
            subtitle: _getYearlySubtitle(),
            badge: widget.turkish ? 'EN İYİ DEĞER' : 'BEST VALUE',
            badgeColor: const Color(0xFF00A86B),
          ),
        
        const SizedBox(height: 12),
        
        // Monthly
        if (_monthlyPackage != null)
          _buildPackageCard(
            package: _monthlyPackage!,
            title: widget.turkish ? 'Aylık' : 'Monthly',
            subtitle: _monthlyPackage!.storeProduct.priceString,
          ),
        
        const SizedBox(height: 12),
        
        // Weekly
        if (_weeklyPackage != null)
          _buildPackageCard(
            package: _weeklyPackage!,
            title: widget.turkish ? 'Haftalık' : 'Weekly',
            subtitle: _weeklyPackage!.storeProduct.priceString,
          ),
      ],
    );
  }

  String _getYearlySubtitle() {
    if (_yearlyPackage == null) return '';
    
    final price = _yearlyPackage!.storeProduct.priceString;
    final savings = _subscriptionService.yearlySavingsPercent;
    
    if (savings != null && savings > 0) {
      return widget.turkish 
          ? '$price/yıl (%$savings tasarruf)'
          : '$price/year ($savings% off)';
    }
    
    return widget.turkish ? '$price/yıl' : '$price/year';
  }

  Widget _buildPackageCard({
    required Package package,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = _selectedPackage == package;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFF00A86B).withAlpha(26)
              : Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF00A86B)
                : Colors.white.withAlpha(26),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFF00A86B)
                      : Colors.white.withAlpha(77),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00A86B),
                        ),
                      ),
                    )
                  : null,
            ),
            
            const SizedBox(width: 16),
            
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(153),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Badge
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? const Color(0xFF00A86B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isPurchasing || _selectedPackage == null 
            ? null 
            : _purchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A86B),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF00A86B).withAlpha(128),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _getButtonText(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  String _getButtonText() {
    if (_selectedPackage == null) {
      return widget.turkish ? 'Paket Seçin' : 'Select Package';
    }
    
    final price = _selectedPackage!.storeProduct.priceString;
    
    switch (_selectedPackage!.packageType) {
      case PackageType.weekly:
        return widget.turkish ? '$price / Hafta' : '$price / Week';
      case PackageType.monthly:
        return widget.turkish ? '$price / Ay' : '$price / Month';
      case PackageType.annual:
        return widget.turkish ? '$price / Yıl' : '$price / Year';
      default:
        return price;
    }
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.turkish
            ? 'Abonelik otomatik olarak yenilenir. İstediğiniz zaman iptal edebilirsiniz. Ödeme, onaylandığında Apple hesabınızdan tahsil edilir.'
            : 'Subscription auto-renews. Cancel anytime. Payment will be charged to your Apple account upon confirmation.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white.withAlpha(102),
        ),
      ),
    );
  }
}

// =============================================================================
// PAYWALL ROUTE HELPER
// =============================================================================

/// Show the paywall as a modal bottom sheet or full screen
/// 
/// Usage:
/// ```dart
/// final purchased = await showProPaywall(context);
/// if (purchased) {
///   // User now has Pro!
/// }
/// ```
Future<bool> showProPaywall(
  BuildContext context, {
  bool fullScreen = true,
  bool turkish = true,
}) async {
  bool purchased = false;
  
  if (fullScreen) {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ProPaywallScreen(
          turkish: turkish,
          onPurchaseSuccess: () {
            purchased = true;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  } else {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: ProPaywallScreen(
            turkish: turkish,
            onPurchaseSuccess: () {
              purchased = true;
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
  
  return purchased;
}
