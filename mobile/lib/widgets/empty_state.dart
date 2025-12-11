import 'package:flutter/material.dart';

class EmptyState extends StatefulWidget {
  final Function(String) onExampleTap;

  const EmptyState({
    super.key,
    required this.onExampleTap,
  });

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  String _titleText = '';
  String _question1Text = '';
  String _question2Text = '';
  String _question3Text = '';
  
  bool _question1Visible = false;
  bool _question2Visible = false;
  bool _question3Visible = false;

  static const String _title = 'Örnek Sorular:';
  static const String _q1 = 'Sabır hakkında ne diyor?';
  static const String _q2 = 'Namaz neden önemlidir?';
  static const String _q3 = 'Zorluklar hakkında ne söyler?';

  @override
  void initState() {
    super.initState();
    _startTypingAnimation();
  }

  Future<void> _startTypingAnimation() async {
    // Başlık - kelime kelime
    await _typeWords(_title, (text) {
      if (mounted) setState(() => _titleText = text);
    });
    
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Soru 1 - kutuyu göster ve kelime kelime yaz
    if (!mounted) return;
    setState(() => _question1Visible = true);
    await Future.delayed(const Duration(milliseconds: 100));
    await _typeWords(_q1, (text) {
      if (mounted) setState(() => _question1Text = text);
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Soru 2
    if (!mounted) return;
    setState(() => _question2Visible = true);
    await Future.delayed(const Duration(milliseconds: 100));
    await _typeWords(_q2, (text) {
      if (mounted) setState(() => _question2Text = text);
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Soru 3
    if (!mounted) return;
    setState(() => _question3Visible = true);
    await Future.delayed(const Duration(milliseconds: 100));
    await _typeWords(_q3, (text) {
      if (mounted) setState(() => _question3Text = text);
    });
  }

  Future<void> _typeWords(String text, Function(String) onUpdate) async {
    final words = text.split(' ');
    String current = '';
    
    for (int i = 0; i < words.length; i++) {
      if (!mounted) return;
      current = words.sublist(0, i + 1).join(' ');
      onUpdate(current);
      await Future.delayed(const Duration(milliseconds: 50)); // Hızlı!
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Başlık
          Text(
            _titleText,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Soru 1
          if (_question1Visible)
            _buildExampleButton(context, _question1Text, _q1),
          if (_question1Visible) const SizedBox(height: 12),
          
          // Soru 2
          if (_question2Visible)
            _buildExampleButton(context, _question2Text, _q2),
          if (_question2Visible) const SizedBox(height: 12),
          
          // Soru 3
          if (_question3Visible)
            _buildExampleButton(context, _question3Text, _q3),
        ],
      ),
    );
  }

  Widget _buildExampleButton(BuildContext context, String displayText, String fullQuestion) {
    return InkWell(
      onTap: () => widget.onExampleTap(fullQuestion),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          displayText.isEmpty ? ' ' : displayText, // Boşluk için minimum yükseklik
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF3E3228),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
