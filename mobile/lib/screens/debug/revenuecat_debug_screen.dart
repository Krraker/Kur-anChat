import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/revenuecat_service.dart';
import '../../services/stable_user_id.dart';

// =============================================================================
// REVENUECAT DEBUG SCREEN
// =============================================================================
//
// Debug screen to verify RevenueCat integration.
// Displays:
// - originalAppUserId
// - Active entitlements
// - isPro status
// - Current offering and packages
//
// Access: Long-press on settings or via hidden dev route
//
// =============================================================================

class RevenueCatDebugScreen extends StatefulWidget {
  const RevenueCatDebugScreen({super.key});

  @override
  State<RevenueCatDebugScreen> createState() => _RevenueCatDebugScreenState();
}

class _RevenueCatDebugScreenState extends State<RevenueCatDebugScreen> {
  final _logs = <String>[];
  bool _isLoading = false;
  
  // Cached data for display
  String? _stableUserId;
  String? _originalAppUserId;
  List<String> _activeEntitlements = [];
  bool _isPro = false;
  String? _currentOfferingId;
  List<_PackageInfo> _packages = [];

  @override
  void initState() {
    super.initState();
    
    // Listen to isPro changes
    RevenueCatService.I.isPro.addListener(_onProStatusChanged);
    
    _runAllChecks();
  }

  @override
  void dispose() {
    RevenueCatService.I.isPro.removeListener(_onProStatusChanged);
    super.dispose();
  }

  void _onProStatusChanged() {
    if (mounted) {
      setState(() {
        _isPro = RevenueCatService.I.isPro.value;
      });
      _log('🔔 isPro changed to: $_isPro');
    }
  }

  void _log(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
    });
    debugPrint('RC_DEBUG: $message');
  }

  Future<void> _runAllChecks() async {
    setState(() {
      _logs.clear();
      _isLoading = true;
    });

    _log('🔄 Starting RevenueCat verification...');
    _log('');

    // === CHECK 1: Stable User ID ===
    _log('━━━ CHECK 1: Stable User ID ━━━');
    try {
      _stableUserId = await StableUserIdService.I.getUserId();
      _log('Stable User ID: $_stableUserId');
      _log('✅ Stable user ID available');
    } catch (e) {
      _log('❌ Error getting stable user ID: $e');
    }
    _log('');

    // === CHECK 2: SDK Configuration ===
    _log('━━━ CHECK 2: SDK Configuration ━━━');
    final isConfigured = RevenueCatService.I.isConfigured;
    _log('Configured: $isConfigured');
    _log('AppUserId used: ${RevenueCatService.I.appUserId}');
    if (!isConfigured) {
      _log('⚠️ SDK not configured! This should not happen.');
    } else {
      _log('✅ SDK configured');
    }
    _log('');

    // === CHECK 3: Customer Info ===
    _log('━━━ CHECK 3: Customer Info ━━━');
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _originalAppUserId = customerInfo.originalAppUserId;
      _activeEntitlements = customerInfo.entitlements.active.keys.toList();
      
      _log('originalAppUserId: $_originalAppUserId');
      _log('Active Entitlements: $_activeEntitlements');
      _log('All Entitlements: ${customerInfo.entitlements.all.keys.toList()}');
      
      // Check consistency
      if (_stableUserId != null && _originalAppUserId != null) {
        // Note: originalAppUserId might have a prefix added by RevenueCat
        final isConsistent = _originalAppUserId!.contains(_stableUserId!) || 
                            _stableUserId == _originalAppUserId;
        if (isConsistent) {
          _log('✅ User ID is consistent');
        } else {
          _log('⚠️ User ID mismatch detected!');
          _log('   Expected: $_stableUserId');
          _log('   Got: $_originalAppUserId');
        }
      }
      
      _log('✅ Customer info retrieved');
    } catch (e) {
      _log('❌ Error getting customer info: $e');
    }
    _log('');

    // === CHECK 4: Entitlement Status ===
    _log('━━━ CHECK 4: KuranChat_Pro Entitlement ━━━');
    _isPro = RevenueCatService.I.isPro.value;
    _log('Entitlement ID: ${RevenueCatService.entitlementId}');
    _log('isPro: $_isPro');
    
    if (_isPro) {
      _log('Current Tier: ${RevenueCatService.I.currentTier}');
      _log('Expires: ${RevenueCatService.I.expirationDate}');
      _log('Will Renew: ${RevenueCatService.I.willRenew}');
      _log('Is Trial: ${RevenueCatService.I.isInTrial}');
      _log('✅ User has Pro access');
    } else {
      _log('ℹ️ User does not have Pro access');
    }
    _log('');

    // === CHECK 5: Offerings ===
    _log('━━━ CHECK 5: Offerings & Packages ━━━');
    try {
      final offerings = await RevenueCatService.I.getOfferings();
      
      if (offerings.current != null) {
        _currentOfferingId = offerings.current!.identifier;
        _log('Current Offering: $_currentOfferingId');
        _log('Packages (${offerings.current!.availablePackages.length}):');
        
        _packages = [];
        for (final pkg in offerings.current!.availablePackages) {
          _packages.add(_PackageInfo(
            type: pkg.packageType.name,
            productId: pkg.storeProduct.identifier,
            price: pkg.storeProduct.priceString,
          ));
          _log('  • ${pkg.packageType.name}');
          _log('    Product: ${pkg.storeProduct.identifier}');
          _log('    Price: ${pkg.storeProduct.priceString}');
        }
        _log('✅ Offerings loaded');
      } else {
        _log('⚠️ No current offering found');
        _log('Available offerings: ${offerings.all.keys.toList()}');
      }
      
      // Check for 'default' offering
      final defaultOffering = offerings.getOffering('default');
      if (defaultOffering != null) {
        _log('');
        _log('✅ "default" offering found with ${defaultOffering.availablePackages.length} packages');
      } else {
        _log('');
        _log('⚠️ "default" offering not found');
      }
    } catch (e) {
      _log('❌ Error loading offerings: $e');
    }
    _log('');

    // === SUMMARY ===
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    final allGood = RevenueCatService.I.isConfigured && _packages.isNotEmpty;
    _log(allGood 
        ? '✅ ALL CHECKS PASSED' 
        : '⚠️ Some checks failed - see above');
    _log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    setState(() => _isLoading = false);
  }

  Future<void> _testPurchase() async {
    final weeklyPkg = await RevenueCatService.I.getWeeklyPackage();
    final monthlyPkg = await RevenueCatService.I.getMonthlyPackage();
    final yearlyPkg = await RevenueCatService.I.getYearlyPackage();
    
    final pkg = weeklyPkg ?? monthlyPkg ?? yearlyPkg;
    
    if (pkg == null) {
      _log('❌ No package available to test');
      return;
    }

    _log('');
    _log('🛒 Testing purchase of ${pkg.packageType.name}...');
    _log('   (Use Sandbox Apple ID when prompted)');
    
    final result = await RevenueCatService.I.buyPackage(pkg);
    
    switch (result) {
      case PurchaseSuccess():
        _log('✅ Purchase successful! isPro: ${RevenueCatService.I.isPro.value}');
        break;
      case PurchaseCancelled():
        _log('ℹ️ Purchase cancelled by user');
        break;
      case PurchaseFailed(:final error):
        _log('❌ Purchase failed: $error');
        break;
    }
    
    // Refresh state
    setState(() {
      _isPro = RevenueCatService.I.isPro.value;
    });
  }

  Future<void> _testRestore() async {
    _log('');
    _log('🔄 Testing restore purchases...');
    
    final result = await RevenueCatService.I.restore();
    
    switch (result) {
      case RestoreSuccess(:final isPro):
        if (isPro) {
          _log('✅ Restore successful! Pro access restored');
        } else {
          _log('ℹ️ Restore completed - No active subscription');
        }
        break;
      case RestoreFailed(:final error):
        _log('❌ Restore failed: $error');
        break;
    }
    
    setState(() {
      _isPro = RevenueCatService.I.isPro.value;
    });
  }

  Future<void> _refreshInfo() async {
    _log('');
    _log('🔄 Refreshing customer info...');
    
    await RevenueCatService.I.refreshCustomerInfo();
    
    setState(() {
      _isPro = RevenueCatService.I.isPro.value;
    });
    
    _log('✅ Refreshed. isPro: $_isPro');
  }

  void _copyLogs() {
    Clipboard.setData(ClipboardData(text: _logs.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logs copied to clipboard')),
    );
  }

  void _printFullDebugState() {
    RevenueCatService.I.debugPrintState();
    _log('');
    _log('📋 Full debug state printed to console');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('RevenueCat Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _printFullDebugState,
            tooltip: 'Print full state',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyLogs,
            tooltip: 'Copy logs',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runAllChecks,
            tooltip: 'Re-run checks',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    title: 'User ID',
                    value: _originalAppUserId ?? 'Loading...',
                    isGood: _originalAppUserId != null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusCard(
                    title: 'isPro',
                    value: _isPro ? 'YES' : 'NO',
                    isGood: true, // Always show as good (just a status)
                    valueColor: _isPro ? const Color(0xFF00A86B) : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testPurchase,
                    icon: const Icon(Icons.shopping_cart, size: 18),
                    label: const Text('Purchase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A86B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _testRestore,
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restore'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _refreshInfo,
                    icon: const Icon(Icons.sync, size: 18),
                    label: const Text('Refresh'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(color: Color(0xFF00A86B)),
            ),
          
          // Logs
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  Color color = Colors.white70;
                  
                  if (log.contains('✅')) color = const Color(0xFF00A86B);
                  if (log.contains('❌')) color = Colors.redAccent;
                  if (log.contains('⚠️')) color = Colors.orange;
                  if (log.contains('ℹ️')) color = Colors.lightBlue;
                  if (log.contains('🔔')) color = Colors.amber;
                  if (log.contains('━━━')) color = Colors.white38;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Bottom status bar
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1A1A1A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatusChip(
                  label: 'Configured',
                  value: RevenueCatService.I.isConfigured,
                ),
                _StatusChip(
                  label: 'Packages',
                  value: _packages.isNotEmpty,
                ),
                _StatusChip(
                  label: 'Pro',
                  value: _isPro,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// HELPER WIDGETS
// =============================================================================

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isGood;
  final Color? valueColor;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.isGood,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.length > 20 ? '${value.substring(0, 20)}...' : value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? (isGood ? Colors.white : Colors.orange),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool value;

  const _StatusChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          color: value ? const Color(0xFF00A86B) : Colors.white38,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: value ? Colors.white : Colors.white38,
          ),
        ),
      ],
    );
  }
}

class _PackageInfo {
  final String type;
  final String productId;
  final String price;

  _PackageInfo({
    required this.type,
    required this.productId,
    required this.price,
  });
}
