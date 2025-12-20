import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/app_gradient_background.dart';
import '../styles/styles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  bool _showChat = false;
  
  // Left side history panel state
  bool _isHistoryPanelOpen = false;
  late AnimationController _panelAnimationController;
  late Animation<Offset> _panelSlideAnimation;
  late Animation<double> _panelFadeAnimation;
  
  // Shine animation for start chat button
  late AnimationController _shineAnimationController;
  
  // Mock chat history data (grouped by date)
  final List<Map<String, dynamic>> _chatHistory = [
    {
      'date': 'Bugün',
      'chats': [
        {'title': 'Namaz vakitleri hakkında', 'preview': 'Sabah namazının vakti...', 'time': '14:30'},
        {'title': 'Fatiha suresi tefsiri', 'preview': 'Fatiha suresinin anlamı...', 'time': '10:15'},
      ],
    },
    {
      'date': 'Dün',
      'chats': [
        {'title': 'Ramazan ayı soruları', 'preview': 'Oruç tutmanın faydaları...', 'time': '18:45'},
        {'title': 'Dua önerileri', 'preview': 'Sabah duaları için...', 'time': '09:20'},
      ],
    },
    {
      'date': '17 Aralık',
      'chats': [
        {'title': 'Kuran okuma tavsiyeleri', 'preview': 'Günlük okuma planı...', 'time': '21:00'},
      ],
    },
    {
      'date': '15 Aralık',
      'chats': [
        {'title': 'Hz. Yusuf kıssası', 'preview': 'Yusuf suresindeki...', 'time': '16:30'},
        {'title': 'Sabır hakkında ayetler', 'preview': 'Sabır ile ilgili...', 'time': '11:00'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize panel animation controller
    _panelAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _panelSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
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
    
    // Initialize shine animation - slow, elegant loop
    _shineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000), // 6 seconds for very slow elegance
    )..repeat(); // Loop forever
  }

  @override
  void dispose() {
    _panelAnimationController.dispose();
    _shineAnimationController.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }
  
  void _toggleHistoryPanel() {
    if (_isHistoryPanelOpen) {
      _panelAnimationController.reverse().then((_) {
        setState(() => _isHistoryPanelOpen = false);
      });
    } else {
      setState(() => _isHistoryPanelOpen = true);
      _panelAnimationController.forward();
    }
  }
  
  void _closeHistoryPanel() {
    if (_isHistoryPanelOpen) {
      _panelAnimationController.reverse().then((_) {
        setState(() => _isHistoryPanelOpen = false);
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _startChat(String? initialMessage) {
    setState(() {
      _showChat = true;
    });
    if (initialMessage != null && initialMessage.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(initialMessage);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final hasMessages = chatProvider.messages.isNotEmpty;
        
        // Auto-switch to chat view if messages exist
        if (hasMessages && !_showChat) {
          _showChat = true;
        }
        
        return Scaffold(
          body: AppGradientBackground(
            child: Stack(
            children: [
              // Content
              if (_showChat || hasMessages)
                _buildChatView(chatProvider)
              else
                _buildHomeView(),
              
              // Top gradient overlay with blur
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
              
              // Header
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
                        // Back button when in chat view (to go back to chat home)
                        if (_showChat)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showChat = false;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                            ),
                          )
                        else
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
                          _showChat ? 'Sohbet' : 'Chat',
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
                        
                        // Refresh button (only in chat)
                        if (_showChat)
                          GestureDetector(
                            onTap: () {
                              chatProvider.clearMessages();
                              setState(() {
                                _showChat = false;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: const Icon(Icons.refresh, color: Colors.white, size: 20),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Floating history chip
              Positioned(
                left: 16,
                top: MediaQuery.of(context).padding.top + 64,
                child: _buildFloatingChip(
                  'Geçmiş Sohbetler',
                  icon: Icons.history,
                  onTap: _toggleHistoryPanel,
                ),
              ),
              
              // Input bar (only when in chat mode)
              if (_showChat)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 130,
                  child: _buildInputBar(chatProvider),
                ),
              
              // Left side history panel
              if (_isHistoryPanelOpen) ...[
                // Backdrop - tap to close
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _closeHistoryPanel,
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
                  top: 0,
                  bottom: 0,
                  child: SlideTransition(
                    position: _panelSlideAnimation,
                    child: _buildHistoryPanel(),
                  ),
                ),
              ],
            ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildFloatingChip(String label, {IconData? icon, VoidCallback? onTap}) {
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHistoryPanel() {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.75;
    final topPadding = MediaQuery.of(context).padding.top + 110;
    
    return SizedBox(
      width: panelWidth + 28,
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
                      // Fixed header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 16, right: 16, top: topPadding - 95, bottom: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.08),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'Sohbetler',
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
                      ),
                      
                      // Scrollable chat history
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(top: 0, bottom: 120),
                          children: [
                            // Chat history grouped by date
                            ..._chatHistory.map((group) => _buildHistoryGroup(group)),
                          ],
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
              alignment: const Alignment(0, 0.15),
              child: GestureDetector(
                onTap: _closeHistoryPanel,
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
  
  Widget _buildHistoryGroup(Map<String, dynamic> group) {
    final date = group['date'] as String;
    final chats = group['chats'] as List<Map<String, String>>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chats for this date - pass date to each item
        ...chats.map((chat) => _buildHistoryChatItem(chat, date)),
      ],
    );
  }
  
  Widget _buildHistoryChatItem(Map<String, String> chat, String date) {
    return GestureDetector(
      onTap: () {
        _closeHistoryPanel();
        // TODO: Load this chat conversation
        _startChat(null);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.08),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat['preview'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Date and time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: GlobalAppStyle.accentColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  chat['time'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 100, // Account for header + chip
        bottom: 140,
      ),
      child: Column(
        children: [
          // Verse of the Day Card
          _buildVerseOfDayCard(),
          
          const SizedBox(height: 16),
          
          // Chat & Reflect Section
          _buildChatReflectSection(),
        ],
      ),
    );
  }

  Widget _buildVerseOfDayCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background image - Beautiful Quran book
            Positioned.fill(
              child: Image.asset(
                'assets/images/daily_surah_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            
            // Subtle dark overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Günün Ayeti',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 12,
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: Center(
                      child: Text(
                        '"Şüphesiz güçlükle beraber bir kolaylık vardır."',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.9),
                              blurRadius: 16,
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 8,
                            ),
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  Text(
                    'İnşirah Suresi 6',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GlobalAppStyle.accentColor,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.9),
                          blurRadius: 12,
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 6,
                        ),
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatReflectSection() {
    final topics = [
      {'label': 'Dua', 'icon': Icons.favorite_border},
      {'label': 'Huzur', 'icon': Icons.self_improvement},
      {'label': 'Tefsir', 'icon': Icons.auto_stories},
      {'label': 'İman', 'icon': Icons.brightness_5},
      {'label': 'Ayet Bul', 'icon': Icons.search},
      {'label': 'Yeni Sohbet', 'icon': Icons.chat_bubble_outline},
      {'label': 'Kıssalar', 'icon': Icons.history_edu},
      {'label': 'Bilgi Yarışması', 'icon': Icons.quiz},
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.75),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Title
          Text(
            'Sohbet & Tefekkür',
            style: TextStyle(
              fontSize: 22,
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
          
          const SizedBox(height: 6),
          
          Text(
            'Bu konularda size yardımcı olabilirim...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Topic chips - wrapped
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: topics.map((topic) {
              return _buildTopicChip(
                topic['label'] as String,
                onTap: () => _startChat('${topic['label']} hakkında bilgi ver'),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // OR divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VEYA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Start new chat button with shine animation
          _buildShineButton(),
        ],
      ),
    );
  }
  
  Widget _buildShineButton() {
    return GestureDetector(
      onTap: () => _startChat(null),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: AnimatedBuilder(
            animation: _shineAnimationController,
            builder: (context, child) {
              return Stack(
                children: [
                  // Base button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.25),
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Yeni sohbet başlat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Shine overlay with fade in/out
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Opacity(
                        // Fade in during first 15%, full opacity in middle, fade out during last 15%
                        opacity: _shineAnimationController.value < 0.15
                            ? (_shineAnimationController.value / 0.15)
                            : _shineAnimationController.value > 0.85
                                ? ((1.0 - _shineAnimationController.value) / 0.15)
                                : 1.0,
                        child: Transform.translate(
                          offset: Offset(
                            // Move from -100 to +400 (left to right across button)
                            -100 + (_shineAnimationController.value * 500),
                            0,
                          ),
                          child: Container(
                            width: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.04),
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.04),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopicChip(String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView(ChatProvider chatProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: MediaQuery.of(context).padding.top + 110, // Account for header + chip
        bottom: 220,
      ),
      itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == chatProvider.messages.length) {
          // Loading indicator
          return _buildLoadingIndicator();
        }
        
        return MessageBubble(
          message: chatProvider.messages[index],
          key: ValueKey(chatProvider.messages[index].id),
          isLatest: index == chatProvider.messages.length - 1,
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFCFC), // Clean white like assistant bubble
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
            child: const JumpingDotsIndicator(
              dotColor: Color(0xFF5C6370), // Gray dots
              dotSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Row(
                children: [
                  Icon(
                    Icons.mic_none,
                    color: Colors.white.withOpacity(0.85),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: 'Kur\'an hakkında bir soru sorun...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      enableSuggestions: false,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          chatProvider.sendMessage(text);
                          _inputController.clear();
                          _scrollToBottom();
                        }
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  GestureDetector(
                    onTap: () {
                      final text = _inputController.text.trim();
                      if (text.isNotEmpty) {
                        chatProvider.sendMessage(text);
                        _inputController.clear();
                        _scrollToBottom();
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        size: 18,
                        color: Colors.black87,
                      ),
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
