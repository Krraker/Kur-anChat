import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/message.dart';
import 'verse_card.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isLatest;

  const MessageBubble({
    super.key,
    required this.message,
    this.isLatest = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  String _displayedText = '';
  int _currentVerseIndex = 0;
  bool _textComplete = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.sender == MessageSender.assistant && widget.isLatest) {
      _animateText();
    } else {
      // Old messages - no animation
      _textComplete = true;
      if (widget.message.sender == MessageSender.assistant) {
        final content = widget.message.content as AssistantMessageContent;
        _displayedText = content.summary;
        _currentVerseIndex = content.verses.length;
      }
    }
  }

  Future<void> _animateText() async {
    if (widget.message.sender != MessageSender.assistant) return;

    final content = widget.message.content as AssistantMessageContent;
    final fullText = content.summary;

    // Always use letter-by-letter typing animation
    for (int i = 0; i <= fullText.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 20));
      setState(() {
        _displayedText = fullText.substring(0, i);
      });
    }

    setState(() {
      _textComplete = true;
    });

    // Show verses one by one
    for (int i = 0; i < content.verses.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _currentVerseIndex = i + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == MessageSender.user;

    if (isUser) {
      // User message - RIGHT (Soft blue-gray for contrast)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 48),
            Flexible(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(4),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      // Warm yellowish cream gradient for clear contrast
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFFFFF8E7).withOpacity(0.98), // Light warm yellow at top
                          const Color(0xFFE8D5B5).withOpacity(0.98), // Warm golden cream at bottom
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(4),
                      ),
                      border: Border.all(
                        color: const Color(0xFFD4B896).withOpacity(0.6),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB8956B).withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _buildUserMessage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Assistant message - LEFT (Clean white/light gray)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      // Clean white for assistant messages
                      color: const Color(0xFFFCFCFC).withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: const Color(0xFFE5E5E5).withOpacity(0.5),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: _buildAssistantMessage(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      );
    }
  }

  Widget _buildUserMessage() {
    final content = widget.message.content as UserMessageContent;
    return Text(
      content.text,
      style: const TextStyle(
        color: Colors.black, // Pure black text
        fontSize: 15,
        height: 1.5,
      ),
    );
  }

  Widget _buildAssistantMessage(BuildContext context) {
    final content = widget.message.content as AssistantMessageContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary with letter-by-letter typing
        Text(
          _displayedText,
          style: const TextStyle(
            color: Color(0xFF3E3228),
            fontSize: 15,
            height: 1.5,
            letterSpacing: 0.1,
          ),
        ),

        // Typing cursor (blinking)
        if (!_textComplete && _displayedText.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: _TypingCursor(),
          ),

        // Verses (Animated)
        if (_currentVerseIndex > 0) ...[
          const SizedBox(height: 16),
          ...List.generate(
            _currentVerseIndex.clamp(0, content.verses.length),
            (index) => AnimatedVerseCard(
              verse: content.verses[index],
              delay: Duration(milliseconds: index * 200),
            ),
          ),
        ],

        // Disclaimer (Only when complete)
        if (_textComplete && content.disclaimer.isNotEmpty) ...[
          const SizedBox(height: 12),
          AnimatedOpacity(
            opacity: _textComplete ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeIn,
            child: Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE8DCC8),
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                content.disclaimer,
                style: const TextStyle(
                  color: Color(0xFF6B5D4F),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// Typing cursor - blinking animation
class _TypingCursor extends StatefulWidget {
  const _TypingCursor();

  @override
  State<_TypingCursor> createState() => _TypingCursorState();
}

class _TypingCursorState extends State<_TypingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 2,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF3E3228),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// Jumping dots loading indicator - ChatGPT style
class JumpingDotsIndicator extends StatefulWidget {
  final Color dotColor;
  final double dotSize;
  
  const JumpingDotsIndicator({
    super.key,
    this.dotColor = const Color(0xFF6B5D4F),
    this.dotSize = 8,
  });

  @override
  State<JumpingDotsIndicator> createState() => _JumpingDotsIndicatorState();
}

class _JumpingDotsIndicatorState extends State<JumpingDotsIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: -8).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }).toList();

    // Start the staggered animation
    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) return;
        _controllers[i].reverse();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(left: index > 0 ? 6 : 0),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

// Animated Verse Card
class AnimatedVerseCard extends StatefulWidget {
  final dynamic verse;
  final Duration delay;

  const AnimatedVerseCard({
    super.key,
    required this.verse,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedVerseCard> createState() => _AnimatedVerseCardState();
}

class _AnimatedVerseCardState extends State<AnimatedVerseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VerseCard(verse: widget.verse),
        ),
      ),
    );
  }
}
