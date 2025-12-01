import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final Function(String) onExampleTap;

  const EmptyState({
    super.key,
    required this.onExampleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Example questions label
            const Text(
              'Örnek Sorular:',
              style: TextStyle(
                fontSize: 18,
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

            // Example questions
            _buildExampleButton(
              context,
              'Sabır hakkında ne diyor?',
              Icons.favorite_border,
            ),
            const SizedBox(height: 12),
            _buildExampleButton(
              context,
              'Namaz neden önemlidir?',
              Icons.self_improvement_rounded,
            ),
            const SizedBox(height: 12),
            _buildExampleButton(
              context,
              'Zorluklar hakkında ne söyler?',
              Icons.lightbulb_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleButton(
    BuildContext context,
    String question,
    IconData icon,
  ) {
    return InkWell(
      onTap: () => onExampleTap(question),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBF0).withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
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
        child: Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF3E3228),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}


