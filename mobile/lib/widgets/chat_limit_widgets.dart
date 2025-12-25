import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/styles.dart';

/// Banner showing remaining messages at the top of chat
class ChatUsageBanner extends StatelessWidget {
  final ChatUsage? usage;
  final VoidCallback onUpgradePressed;

  const ChatUsageBanner({
    super.key,
    required this.usage,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (usage == null) return const SizedBox.shrink();

    final isPremium = usage!.isPremium;
    final remaining = usage!.remainingMessages;

    // Don't show banner for premium users with unlimited
    if (isPremium && usage!.isUnlimited) return const SizedBox.shrink();

    // Color scheme based on remaining messages
    final isLow = remaining <= 1 && remaining >= 0;
    final primaryColor = isLow ? Colors.orange : Colors.green;
    final backgroundColor = primaryColor.withOpacity(0.1);
    final borderColor = primaryColor.withOpacity(0.3);
    final textColor = isLow ? Colors.orange[900]! : Colors.green[800]!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(
            isLow ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              remaining == -1
                  ? '✨ Premium: Sınırsız mesaj'
                  : remaining > 0
                      ? 'Bugün $remaining mesajınız kaldı'
                      : 'Günlük limit doldu',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          if (isLow && !isPremium)
              TextButton(
              onPressed: onUpgradePressed,
              style: TextButton.styleFrom(
                backgroundColor: GlobalAppStyle.accentColor.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Yükselt',
                style: TextStyle(
                  color: GlobalAppStyle.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog shown when user hits the 3-message limit (Glassmorphism)
class ChatLimitDialog extends StatefulWidget {
  final VoidCallback onUpgradePressed;
  final String resetTimeText;

  const ChatLimitDialog({
    super.key,
    required this.onUpgradePressed,
    required this.resetTimeText,
  });

  @override
  State<ChatLimitDialog> createState() => _ChatLimitDialogState();
}

class _ChatLimitDialogState extends State<ChatLimitDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 50,
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                // Dark glassmorphism like your calendar
                color: const Color(0xFF1A2621).withOpacity(0.75), // More transparent for better blur visibility
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Content area (Calendar style - dark theme)
                  Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        // Icon with calendar-style background
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.lock_clock,
                            size: 40,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Title
                        Text(
                          'Günlük Limit Doldu',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          'Ücretsiz kullanıcılar günde 3 mesaj gönderebilir.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.resetTimeText} yeniden deneyin veya Premium\'a yükseltin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                            height: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Buttons (Premium style)
                        Column(
                          children: [
                            // Pro button (bigger, premium gold)
                            _PremiumProButton(
                              onPressed: () {
                                Navigator.pop(context);
                                widget.onUpgradePressed();
                              },
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Kapat button (secondary)
                            _CalendarButton(
                              label: 'Kapat',
                              onPressed: () => Navigator.pop(context),
                              isPrimary: false,
                            ),
                          ],
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
    );
  }
}

/// Premium Pro button with gold gradient and animations
class _PremiumProButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PremiumProButton({required this.onPressed});

  @override
  State<_PremiumProButton> createState() => _PremiumProButtonState();
}

class _PremiumProButtonState extends State<_PremiumProButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulseValue = (0.5 - (_controller.value - 0.5).abs()) * 2;
        
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD700), // Gold
                  Color(0xFFFFA500), // Orange
                  Color(0xFFFF8C00), // Dark orange
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.3 + pulseValue * 0.2),
                  blurRadius: 20 + pulseValue * 10,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 22,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  'Pro\'ya Geç',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Calendar-style button (dark glassmorphism theme)
class _CalendarButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _CalendarButton({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withOpacity(0.08),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

/// Show the limit dialog (Calendar glassmorphism style)
void showChatLimitDialog(
  BuildContext context, {
  required VoidCallback onUpgradePressed,
  required String resetTimeText,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.7), // Darker barrier for better blur effect
    builder: (context) => ChatLimitDialog(
      onUpgradePressed: onUpgradePressed,
      resetTimeText: resetTimeText,
    ),
  );
}

