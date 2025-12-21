import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../styles/styles.dart';
import '../widgets/app_gradient_background.dart';
import '../services/api_config.dart';
import '../services/reading_progress_service.dart';
import '../models/message.dart' show decodeHtmlEntities;

/// Quran reading screen - with API integration
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with SingleTickerProviderStateMixin {
  String selectedSurah = 'Fatiha';
  int selectedSurahNumber = 1;
  String selectedTranslation = 'Diyanet';
  
  List<Map<String, dynamic>> _verses = [];
  bool _isLoading = true;
  String? _error;
  
  // Left side panel state
  bool _isSurahPanelOpen = false;
  late AnimationController _panelAnimationController;
  late Animation<Offset> _panelSlideAnimation;
  late Animation<double> _panelFadeAnimation;
  
  // Reading progress service
  final ReadingProgressService _progressService = ReadingProgressService();
  final ScrollController _scrollController = ScrollController();
  Set<int> _visibleVerses = {};
  int _lastDisplayedProgress = -1; // Track last displayed percentage

  @override
  void initState() {
    super.initState();
    _initProgress();
    _loadSurah(1);
    
    // Track visible verses for progress
    _scrollController.addListener(_onScroll);
    
    // Initialize panel animation controller
    _panelAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _panelSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start from left (off-screen)
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    
    _panelFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.easeOut,
    ));
  }
  
  Future<void> _initProgress() async {
    await _progressService.init();
    if (mounted) setState(() {});
  }
  
  void _onScroll() {
    // Mark verses as read after 2 seconds of being visible
    // For now, we'll mark verses as read when scrolled past
    _markVisibleVersesAsRead();
  }
  
  void _markVisibleVersesAsRead() {
    // Simplified: mark all loaded verses up to current scroll position as read
    if (_verses.isEmpty || !_scrollController.hasClients) return;
    
    // Calculate approximately which verses are visible/read
    final scrollPosition = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    // Approximate verse height (including translation)
    const approxVerseHeight = 120.0;
    final headerOffset = MediaQuery.of(context).padding.top + 132;
    
    // Calculate last visible verse index
    final lastVisible = ((scrollPosition + viewportHeight - headerOffset) / approxVerseHeight).ceil();
    
    // Mark verses as read (up to current visible position)
    final versesToMark = <int>[];
    for (int i = 0; i <= lastVisible && i < _verses.length; i++) {
      final verseNum = _verses[i]['number'] as int? ?? (i + 1);
      if (!_visibleVerses.contains(verseNum)) {
        _visibleVerses.add(verseNum);
        versesToMark.add(verseNum);
      }
    }
    
    if (versesToMark.isNotEmpty) {
      _progressService.markVersesRead(selectedSurahNumber, versesToMark);
    }
    
    // Only trigger rebuild when progress percentage changes (for smooth but efficient updates)
    final currentProgress = (_progressService.getSurahProgress(selectedSurahNumber) * 100).round();
    if (currentProgress != _lastDisplayedProgress) {
      _lastDisplayedProgress = currentProgress;
      if (mounted) setState(() {});
    }
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _panelAnimationController.dispose();
    super.dispose();
  }
  
  void _toggleSurahPanel() {
    if (_isSurahPanelOpen) {
      _panelAnimationController.reverse().then((_) {
        setState(() => _isSurahPanelOpen = false);
      });
    } else {
      setState(() => _isSurahPanelOpen = true);
      _panelAnimationController.forward();
    }
  }
  
  void _closeSurahPanel() {
    if (_isSurahPanelOpen) {
      _panelAnimationController.reverse().then((_) {
        setState(() => _isSurahPanelOpen = false);
      });
    }
  }

  /// Safely extract and sanitize string from API response
  String _safeString(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final str = value.toString();
    // Remove any invalid UTF-16 characters that could cause rendering issues
    return str.replaceAll(RegExp(r'[\uD800-\uDFFF](?![\uDC00-\uDFFF])|(?<![\uD800-\uDBFF])[\uDC00-\uDFFF]'), '');
  }

  Future<void> _loadSurah(int surahNumber) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _visibleVerses = {}; // Reset visible verses for new surah
      _lastDisplayedProgress = -1; // Reset progress display for new surah
    });

    try {
      final config = ApiConfig();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quran/surah/$surahNumber'),
        headers: config.headers,
      ).timeout(config.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Safely handle null or missing verses array
        final versesList = data['verses'];
        if (versesList == null || versesList is! List || versesList.isEmpty) {
          setState(() {
            _error = 'Ayet verisi bulunamadı';
            _isLoading = false;
          });
          return;
        }
        
        final verses = versesList.map((v) {
          if (v == null) return <String, dynamic>{};
          return <String, dynamic>{
            'number': v['ayah'] ?? v['number'] ?? 0,
            'arabic': _safeString(decodeHtmlEntities(_safeString(v['arabic'] ?? v['text_ar']))),
            'translation': _safeString(decodeHtmlEntities(_safeString(v['turkish'] ?? v['text_tr']))),
          };
        }).where((v) => v.isNotEmpty).toList();

        setState(() {
          _verses = List<Map<String, dynamic>>.from(verses);
          selectedSurahNumber = surahNumber;
          selectedSurah = _safeString(data['name'], _getSurahName(surahNumber));
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Sureler yüklenemedi (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bağlantı hatası: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).padding.top + 72;
    
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
        children: [
          // Scrollable verses content - starts from top, scrolls under header
          _isLoading
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: headerHeight + 60),
                    child: const CircularProgressIndicator(
                      color: GlobalAppStyle.accentColor,
                    ),
                  ),
                )
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: headerHeight + 60),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white.withOpacity(0.5),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadSurah(selectedSurahNumber),
                              child: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: headerHeight + 60,
                        bottom: 200,
                      ),
                      itemCount: _verses.length,
                      itemBuilder: (context, index) {
                        final verse = _verses[index];
                        return _buildVerseItem(verse);
                      },
                    ),
          
          // Header blur overlay (same as other pages)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: MediaQuery.of(context).padding.top + 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.7, 1.0],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Header content on top
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: 40,
                child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          GlobalAppStyle.accentColor,
                          GlobalAppStyle.accentColor.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GlobalAppStyle.accentColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'K',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 14),
                  
                  // Title
                  Text(
                    'Kur\'an',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Search Icon
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    onPressed: () {},
                  ),
                  
                  // More options
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    onPressed: () {},
                  ),
                ],
                ),
              ),
            ),
          ),
          
          // Floating selector chips with nav-bar glassmorphism
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 64,
            child: Row(
              children: [
                // Search icon - opens surah panel
                _buildFloatingIconChip(
                  Icons.search,
                  onTap: _toggleSurahPanel,
                ),
                const SizedBox(width: 8),
                // Surah chip - display only
                _buildFloatingChip(
                  '$selectedSurah $selectedSurahNumber',
                ),
                const SizedBox(width: 8),
                // Translation chip
                _buildFloatingChip(
                  selectedTranslation,
                  onTap: () => _showTranslationSelector(),
                ),
              ],
            ),
          ),
          
          // Progress indicator on right side of header
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 64,
            child: _buildProgressIndicator(),
          ),
          
          // Bottom navigation controls - floating glassmorphism buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous surah button
                  _buildNavButton(
                    Icons.chevron_left,
                    onTap: selectedSurahNumber > 1
                        ? () => _loadSurah(selectedSurahNumber - 1)
                        : null,
                  ),
                  
                  // Play/Audio button
                  _buildNavButton(
                    Icons.play_arrow,
                    isCenter: true,
                    onTap: () {
                      // TODO: Audio playback
                    },
                  ),
                  
                  // Next surah button
                  _buildNavButton(
                    Icons.chevron_right,
                    onTap: selectedSurahNumber < 114
                        ? () => _loadSurah(selectedSurahNumber + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          
          // Left side surah selector panel (above content, below header & above navbar)
          if (_isSurahPanelOpen) ...[
            // Backdrop - tap to close
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSurahPanel,
                child: FadeTransition(
                  opacity: _panelFadeAnimation,
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            
            // The slide-in panel from left
            Positioned(
              left: 0,
              top: 0, // Start from top edge (under header)
              bottom: 0, // Extend to bottom edge
              child: SlideTransition(
                position: _panelSlideAnimation,
                child: _buildLeftSurahPanel(),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }
  
  Widget _buildLeftSurahPanel() {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.75; // 75% of screen width
    final topPadding = MediaQuery.of(context).padding.top + 110; // Below notch + header + chips
    
    return SizedBox(
      width: panelWidth + 28, // Extra space for the edge button
      child: Stack(
        children: [
          // Main panel
          Container(
            width: panelWidth,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(10, 0),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withOpacity(0.15),
                        width: 0.5,
                      ),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.02),
                      ],
                      stops: const [0.0, 0.3, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Fixed header - stays still while content scrolls
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 12, right: 12, top: topPadding - 95, bottom: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Sureler',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Search group (input + magnifier)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 100,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withOpacity(0.08),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: TextField(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Ara...',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.4),
                                        fontSize: 13,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      // TODO: Filter surahs based on search
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.search,
                                  size: 22,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Scrollable surah list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 0, bottom: 120),
                          itemCount: 114, // 114 surahs
                          itemBuilder: (context, index) {
                final surahNumber = index + 1; // index 0 = surah 1, etc.
                final isSelected = selectedSurahNumber == surahNumber;
                final progress = _progressService.getSurahProgress(surahNumber);
                final isCompleted = progress >= 1.0;
                final hasProgress = progress > 0;
                
                return GestureDetector(
                  onTap: () {
                    _closeSurahPanel();
                    _loadSurah(surahNumber);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.08),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: isSelected 
                            ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.08)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.05),
                                    width: 0.5,
                                  )
                                : null,
                          ),
                          child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Surah number (no circle)
                            SizedBox(
                              width: 32,
                              child: Text(
                                '$surahNumber',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? GlobalAppStyle.accentColor
                                      : Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Surah name
                            Expanded(
                              child: Text(
                                _getSurahName(surahNumber),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? GlobalAppStyle.accentColor
                                      : Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            // Progress percentage or check mark
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: GlobalAppStyle.accentColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: GlobalAppStyle.accentColor,
                                  size: 14,
                                ),
                              )
                            else if (hasProgress)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: GlobalAppStyle.accentColor.withOpacity(0.9),
                                  ),
                                ),
                              )
                            else if (isSelected)
                              Icon(
                                Icons.check,
                                color: GlobalAppStyle.accentColor,
                                size: 18,
                              ),
                          ],
                        ),
                        // Progress bar (only show if there's some progress but not complete)
                        if (hasProgress && !isCompleted) ...[
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                GlobalAppStyle.accentColor.withOpacity(0.7),
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ],
                        // Completed indicator bar
                        if (isCompleted) ...[
                          const SizedBox(height: 8),
                          Container(
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: GlobalAppStyle.accentColor.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ),
                  ),
                  ),
                );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Minimize arrow button on the right edge
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: const Alignment(0, 0.15), // Slightly below center like Sohbetler
              child: GestureDetector(
                onTap: _closeSurahPanel,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
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
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white.withOpacity(0.9),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    // Get current surah's progress
    final surahProgress = _progressService.getSurahProgress(selectedSurahNumber);
    final percentageInt = (surahProgress * 100).round();
    final isCompleted = surahProgress >= 1.0;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.08),
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
                  Colors.white.withOpacity(0.02),
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress notches (5 notches for current surah progress)
                ...List.generate(5, (i) {
                  final notchThreshold = (i + 1) * 0.2; // 20%, 40%, 60%, 80%, 100%
                  final notchStart = i * 0.2;
                  final isFilled = surahProgress >= notchThreshold;
                  // Calculate partial fill for smoother animation
                  final isPartial = surahProgress > notchStart && surahProgress < notchThreshold;
                  final partialAmount = isPartial 
                      ? ((surahProgress - notchStart) / 0.2).clamp(0.0, 1.0) 
                      : 0.0;
                  
                  return Container(
                    width: 4,
                    height: 14,
                    margin: EdgeInsets.only(right: i < 4 ? 3 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isFilled
                          ? GlobalAppStyle.accentColor
                          : isPartial
                              ? GlobalAppStyle.accentColor.withOpacity(0.3 + (partialAmount * 0.7))
                              : Colors.white.withOpacity(0.2),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                // Show percentage
                if (isCompleted)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: GlobalAppStyle.accentColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '100%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: GlobalAppStyle.accentColor,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    '$percentageInt%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingChip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
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
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
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

  Widget _buildFloatingIconChip(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
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
              child: Icon(
                icon,
                size: 18,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerseItem(Map<String, dynamic> verse) {
    // Safely extract verse data with defaults
    final verseNumber = verse['number'] ?? 0;
    final arabicText = _safeString(verse['arabic']);
    final translationText = _safeString(verse['translation']);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Arabic text row (RTL - verse number on right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl, // RTL layout
            children: [
              // Verse number (on the right for RTL)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: GlobalAppStyle.accentColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$verseNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: GlobalAppStyle.accentColor,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Arabic text (right-to-left, right-aligned)
              Expanded(
                child: Text(
                  arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.8,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Translation (left-to-right, left-aligned)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              translationText,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, {bool isCenter = false, VoidCallback? onTap}) {
    final size = isCenter ? 56.0 : 48.0;
    final iconSize = isCenter ? 28.0 : 22.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
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
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white.withOpacity(0.9),
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTranslationSelector() {
    // TODO: Implement translation selector
  }

  String _getSurahName(int number) {
    const surahNames = [
      'Fatiha', 'Bakara', 'Âl-i İmran', 'Nisa', 'Maide',
      'En\'am', 'A\'raf', 'Enfal', 'Tevbe', 'Yunus',
      'Hud', 'Yusuf', 'Ra\'d', 'İbrahim', 'Hicr',
      'Nahl', 'İsra', 'Kehf', 'Meryem', 'Taha',
      'Enbiya', 'Hac', 'Mü\'minun', 'Nur', 'Furkan',
      'Şuara', 'Neml', 'Kasas', 'Ankebut', 'Rum',
      'Lokman', 'Secde', 'Ahzab', 'Sebe', 'Fatır',
      'Yasin', 'Saffat', 'Sad', 'Zümer', 'Mü\'min',
      'Fussilet', 'Şura', 'Zuhruf', 'Duhan', 'Casiye',
      'Ahkaf', 'Muhammed', 'Fetih', 'Hucurat', 'Kaf',
      'Zariyat', 'Tur', 'Necm', 'Kamer', 'Rahman',
      'Vakıa', 'Hadid', 'Mücadele', 'Haşr', 'Mümtehine',
      'Saf', 'Cum\'a', 'Münafikun', 'Teğabün', 'Talak',
      'Tahrim', 'Mülk', 'Kalem', 'Hakka', 'Mearic',
      'Nuh', 'Cin', 'Müzzemmil', 'Müddessir', 'Kıyamet',
      'İnsan', 'Mürselat', 'Nebe', 'Naziat', 'Abese',
      'Tekvir', 'İnfitar', 'Mutaffifin', 'İnşikak', 'Büruc',
      'Tarık', 'A\'la', 'Ğaşiye', 'Fecr', 'Beled',
      'Şems', 'Leyl', 'Duha', 'İnşirah', 'Tin',
      'Alak', 'Kadr', 'Beyyine', 'Zilzal', 'Adiyat',
      'Karia', 'Tekasür', 'Asr', 'Hümeze', 'Fil',
      'Kureyş', 'Maun', 'Kevser', 'Kafirun', 'Nasr',
      'Tebbet', 'İhlas', 'Felak', 'Nas',
    ];
    if (number <= surahNames.length) {
      return surahNames[number - 1];
    }
    return 'Sure $number';
  }
}

