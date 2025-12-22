import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/audio_service.dart';

/// Dynamic Island style audio player - Pure Glassmorphism
class AudioPlayerIsland extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onTap;

  const AudioPlayerIsland({
    super.key,
    this.onClose,
    this.onTap,
  });

  @override
  State<AudioPlayerIsland> createState() => _AudioPlayerIslandState();
}

class _AudioPlayerIslandState extends State<AudioPlayerIsland> {
  final QuranAudioService _audioService = QuranAudioService();

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentVerse = _audioService.currentVerse;
    if (currentVerse == null && _audioService.state == AudioPlaybackState.idle) {
      return const SizedBox.shrink();
    }

    final isLoading = _audioService.isLoading;
    final isPlaying = _audioService.isPlaying;

    // Fixed height for the island
    const double islandHeight = 56.0;
    // Equal padding on all sides for the play button
    const double buttonPadding = 8.0;
    const double buttonSize = islandHeight - (buttonPadding * 2); // 40px

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: islandHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(islandHeight / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(islandHeight / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(islandHeight / 2),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.18),
                    Colors.white.withOpacity(0.06),
                    Colors.white.withOpacity(0.02),
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: buttonPadding),
                child: Row(
                  children: [
                    // Play/Pause button - equal spacing from top, left, bottom
                    _buildPlayButton(
                      size: buttonSize,
                      isLoading: isLoading,
                      isPlaying: isPlaying,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Verse info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentVerse?.surahName ?? 'Sure ${currentVerse?.surah ?? 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ayet ${currentVerse?.ayah ?? 1}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Close button
                    GestureDetector(
                      onTap: () {
                        _audioService.stop();
                        widget.onClose?.call();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.7),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayButton({
    required double size,
    required bool isLoading,
    required bool isPlaying,
  }) {
    return GestureDetector(
      onTap: () async {
        if (isPlaying) {
          await _audioService.pause();
        } else if (_audioService.isPaused) {
          await _audioService.resume();
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.15),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: size * 0.45,
                  height: size * 0.45,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.9),
                    ),
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white.withOpacity(0.9),
                  size: size * 0.55,
                ),
        ),
      ),
    );
  }
}

/// Verse play button - can be embedded in verse items
class VersePlayButton extends StatefulWidget {
  final int surah;
  final int ayah;
  final String? surahName;
  final String? textTr;
  final double size;

  const VersePlayButton({
    super.key,
    required this.surah,
    required this.ayah,
    this.surahName,
    this.textTr,
    this.size = 36,
  });

  @override
  State<VersePlayButton> createState() => _VersePlayButtonState();
}

class _VersePlayButtonState extends State<VersePlayButton> {
  final QuranAudioService _audioService = QuranAudioService();
  bool _isThisVersePlaying = false;

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      final currentVerse = _audioService.currentVerse;
      final isPlaying = currentVerse?.surah == widget.surah && 
                        currentVerse?.ayah == widget.ayah &&
                        (_audioService.isPlaying || _audioService.isLoading);
      
      if (_isThisVersePlaying != isPlaying) {
        setState(() => _isThisVersePlaying = isPlaying);
      }
    }
  }

  Future<void> _handleTap() async {
    if (_isThisVersePlaying) {
      if (_audioService.isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.resume();
      }
    } else {
      await _audioService.playVerse(
        surah: widget.surah,
        ayah: widget.ayah,
        surahName: widget.surahName,
        textTr: widget.textTr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isThisVersePlaying && _audioService.isLoading;
    final isPlaying = _isThisVersePlaying && _audioService.isPlaying;

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isThisVersePlaying 
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: widget.size * 0.45,
                  height: widget.size * 0.45,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.9),
                    ),
                  ),
                )
              : Icon(
                  isPlaying ? Icons.pause : Icons.volume_up_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: widget.size * 0.5,
                ),
        ),
      ),
    );
  }
}
