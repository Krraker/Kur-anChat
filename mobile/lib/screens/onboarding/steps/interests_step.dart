import 'package:flutter/material.dart';

class InterestsStep extends StatefulWidget {
  final String? interests;
  final Function(String) onInterestsChanged;
  final String? language;

  const InterestsStep({
    super.key,
    required this.interests,
    required this.onInterestsChanged,
    this.language,
  });

  @override
  State<InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<InterestsStep> {
  late TextEditingController _controller;

  bool get isEnglish => widget.language == 'en';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.interests);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            isEnglish 
                ? 'The Quran is vast. What topics interest you?'
                : 'Kur\'an geniş bir kaynak. Hangi konular ilginizi çekiyor?',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            isEnglish 
                ? 'Your privacy is guaranteed and your information will remain confidential.'
                : 'Gizliliğiniz garanti altındadır ve bilgileriniz gizli kalacaktır.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Text input
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: isEnglish ? 'Describe here...' : 'Buraya yazın...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: widget.onInterestsChanged,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            isEnglish 
                ? 'Your privacy is guaranteed and your information will remain confidential.'
                : 'Gizliliğiniz garanti altındadır ve bilgileriniz gizli kalacaktır.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}
