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
  
  // Satır satır animasyon için
  List<String> _sentences = [];
  int _currentSentenceIndex = 0;
  bool _useSentenceAnimation = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.sender == MessageSender.assistant && widget.isLatest) {
      _animateText();
    } else {
      // Eski mesajlar için animasyon yok
      _textComplete = true;
      if (widget.message.sender == MessageSender.assistant) {
        final content = widget.message.content as AssistantMessageContent;
        _displayedText = content.summary;
        _currentVerseIndex = content.verses.length;
        
        // Eski mesajlar için de cümlelere böl
        final sentencePattern = RegExp(r'[.!?]+\s*');
        final sentences = content.summary.split(sentencePattern).where((s) => s.trim().isNotEmpty).toList();
        _sentences = sentences;
        _currentSentenceIndex = sentences.length;
        _useSentenceAnimation = sentences.length > 3 || content.summary.length > 200;
      }
    }
  }

  Future<void> _animateText() async {
    if (widget.message.sender != MessageSender.assistant) return;

    final content = widget.message.content as AssistantMessageContent;
    final fullText = content.summary;

    // Metni cümlelere böl (nokta, soru işareti, ünlem işaretinden sonra)
    final sentencePattern = RegExp(r'[.!?]+\s*');
    final sentences = fullText.split(sentencePattern).where((s) => s.trim().isNotEmpty).toList();
    
    // Uzun mu kontrol et (3'ten fazla cümle VEYA 200 karakterden uzun)
    final isLongText = sentences.length > 3 || fullText.length > 200;

    if (isLongText) {
      // UZUN METİN: Cümle cümle smooth fade-in
      setState(() {
        _useSentenceAnimation = true;
        _sentences = sentences;
      });

      // Cümleleri sırayla göster - baloncuk büyüsün
      for (int i = 0; i < sentences.length; i++) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 400));
        setState(() {
          _currentSentenceIndex = i + 1;
        });
      }
    } else {
      // KISA METİN: Karakter karakter typing animasyonu
      setState(() {
        _useSentenceAnimation = false;
      });
      
      for (int i = 0; i <= fullText.length; i++) {
        if (!mounted) return;
        await Future.delayed(const Duration(milliseconds: 25));
        setState(() {
          _displayedText = fullText.substring(0, i);
        });
      }
    }

    setState(() {
      _textComplete = true;
    });

    // Ayetleri sırayla göster
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
      // Kullanıcı mesajı - SAĞDA (Glassmorphism)
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
                      color: const Color(0xFFFFF4E0).withOpacity(0.75), // Semi-transparent
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(4),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
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
                    child: _buildUserMessage(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Asistan mesajı - SOLDA (Glassmorphism)
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
                      color: const Color(0xFFFFFBF0).withOpacity(0.85), // Semi-transparent
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(4),
                        bottomRight: Radius.circular(20),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
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
        color: Color(0xFF4A3E2A), // Koyu kahverengi text
        fontSize: 18,
        height: 1.5,
      ),
    );
  }

  Widget _buildAssistantMessage(BuildContext context) {
    final content = widget.message.content as AssistantMessageContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary (Animasyonlu)
        if (_useSentenceAnimation)
          // UZUN METİN: Cümle cümle fade-in
          _buildSentenceBySeentenceText()
        else
          // KISA METİN: Karakter karakter typing
          Text(
            _displayedText,
            style: const TextStyle(
              color: Color(0xFF3E3228),
              fontSize: 18,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),

        // Typing cursor (yanıp sönen) - sadece karakter animasyonu için
        if (!_useSentenceAnimation && !_textComplete && _displayedText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _TypingIndicator(),
          ),

        // Verses (Animasyonlu)
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

        // Disclaimer (Sadece tamamlandığında)
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
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Cümle cümle smooth fade-in animasyonu - baloncuk büyüsün
  Widget _buildSentenceBySeentenceText() {
    // Sadece görünür cümleleri göster (baloncuk büyüsün)
    if (_currentSentenceIndex == 0) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      children: List.generate(_currentSentenceIndex, (index) {
        final sentence = _sentences[index];
        final isLatestSentence = index == _currentSentenceIndex - 1;
        final shouldAnimate = isLatestSentence && !_textComplete;
        
        return _FadeInSentence(
          key: ValueKey('sentence_$index'),
          sentence: sentence + (index < _sentences.length - 1 ? '. ' : ''),
          isLatest: isLatestSentence,
          isComplete: _textComplete,
          shouldAnimate: shouldAnimate, // Sadece son cümle animate olsun
        );
      }),
    );
  }
}

// Fade-in sentence widget - Smooth opacity animation
class _FadeInSentence extends StatefulWidget {
  final String sentence;
  final bool isLatest;
  final bool isComplete;
  final bool shouldAnimate;

  const _FadeInSentence({
    super.key,
    required this.sentence,
    required this.isLatest,
    required this.isComplete,
    required this.shouldAnimate,
  });

  @override
  State<_FadeInSentence> createState() => _FadeInSentenceState();
}

class _FadeInSentenceState extends State<_FadeInSentence>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Sadece animate edilmesi gereken cümle için animasyonu başlat
    if (widget.shouldAnimate) {
      _controller.forward();
    } else {
      // Eski cümleler direkt görünsün
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Text(
        widget.sentence,
        style: TextStyle(
          color: const Color(0xFF3E3228),
          fontSize: 18,
          height: 1.6,
          letterSpacing: 0.2,
          fontWeight: widget.isLatest && !widget.isComplete ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}

// Typing indicator widget - Animated
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({Key? key}) : super(key: key);

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF22c55e),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22c55e).withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
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

    // Smooth fade in with opacity
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Gentle slide up
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


