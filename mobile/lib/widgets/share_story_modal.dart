import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/share_story_service.dart';
import '../styles/styles.dart';

/// Data model for share content
class ShareContent {
  final String arabicText;
  final String turkishText;
  final String surahName;
  final String? verseNumber;

  const ShareContent({
    required this.arabicText,
    required this.turkishText,
    required this.surahName,
    this.verseNumber,
  });
}

/// Modal for sharing daily verses/prayers to Instagram Stories
class ShareStoryModal extends StatefulWidget {
  final ShareContent content;

  const ShareStoryModal({
    super.key,
    required this.content,
  });

  /// Show the share modal
  static Future<void> show(BuildContext context, ShareContent content) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareStoryModal(content: content),
    );
  }

  @override
  State<ShareStoryModal> createState() => _ShareStoryModalState();
}

class _ShareStoryModalState extends State<ShareStoryModal> {
  int _selectedBackgroundIndex = 0;
  final GlobalKey _storyKey = GlobalKey();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            color: Colors.white.withOpacity(0.1),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.7),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Hikayende Paylaş',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

          // Story Preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: RepaintBoundary(
                    key: _storyKey,
                    child: _buildStoryContent(),
                  ),
                ),
              ),
            ),
          ),

          // Background Picker
          const SizedBox(height: 20),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: ShareStoryService.backgrounds.length,
              itemBuilder: (context, index) => _buildBackgroundOption(index),
            ),
          ),

          // Action Buttons
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Save to Gallery
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.save_alt_rounded,
                    label: 'Kaydet',
                    onTap: _saveToGallery,
                  ),
                ),
                const SizedBox(width: 12),
                // Share
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    icon: Icons.share_rounded,
                    label: 'Paylaş',
                    isPrimary: true,
                    onTap: _shareStory,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background with subtle blur
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
          child: Image.asset(
            ShareStoryService.backgrounds[_selectedBackgroundIndex],
            fit: BoxFit.cover,
          ),
        ),
        
        // Subtle vignette overlay
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),

        // Content - Centered with flex distribution
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                // Top spacing
                const Spacer(flex: 3),
                
                // Main content block - centered
                Flexible(
                  flex: 8,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Arabic Text - compact
                      Flexible(
                        child: Text(
                          widget.content.arabicText,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          overflow: TextOverflow.fade,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.7),
                                blurRadius: 12,
                              ),
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Elegant divider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 0.5,
                            color: Colors.white.withOpacity(0.4),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: GlobalAppStyle.accentColor.withOpacity(0.8),
                              boxShadow: [
                                BoxShadow(
                                  color: GlobalAppStyle.accentColor.withOpacity(0.4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 0.5,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Turkish Text - ChiswellMedian italic quote font
                      Flexible(
                        child: Text(
                          '"${widget.content.turkishText}"',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.fade,
                          maxLines: 6,
                          style: const TextStyle(
                            fontFamily: 'ChiswellMedian',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.5,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                              ),
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 14),
                      
                      // Surah badge - minimal
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          widget.content.verseNumber != null
                              ? '${widget.content.surahName} • ${widget.content.verseNumber}'
                              : widget.content.surahName,
                          style: TextStyle(
                            fontFamily: 'OggText',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom spacing with logo
                const Spacer(flex: 2),
                
                // App branding - subtle
                Opacity(
                  opacity: 0.6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/allah_icon.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Kur\'an Chat',
                        style: TextStyle(
                          fontFamily: 'OggText',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundOption(int index) {
    final isSelected = _selectedBackgroundIndex == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedBackgroundIndex = index),
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? GlobalAppStyle.accentColor 
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GlobalAppStyle.accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            ShareStoryService.backgrounds[index],
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isPrimary
                  ? GlobalAppStyle.accentColor.withOpacity(0.9)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPrimary
                    ? GlobalAppStyle.accentColor
                    : Colors.white.withOpacity(0.15),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        isPrimary ? Colors.white : Colors.white.withOpacity(0.7),
                      ),
                    ),
                  )
                else ...[
                  Icon(
                    icon,
                    size: 20,
                    color: isPrimary ? Colors.white : Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isPrimary ? Colors.white : Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveToGallery() async {
    setState(() => _isLoading = true);
    
    try {
      final imageBytes = await ShareStoryService.captureWidget(_storyKey);
      if (imageBytes != null) {
        final success = await ShareStoryService.saveToGallery(imageBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success 
                    ? 'Galeriye kaydedildi!' 
                    : 'Kaydetme başarısız. Lütfen izinleri kontrol edin.',
              ),
              backgroundColor: success ? GlobalAppStyle.accentColor : Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _shareStory() async {
    setState(() => _isLoading = true);
    
    try {
      final imageBytes = await ShareStoryService.captureWidget(_storyKey);
      if (imageBytes != null) {
        await ShareStoryService.shareImage(imageBytes);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}






