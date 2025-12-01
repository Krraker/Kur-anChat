import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/empty_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/GettyImages-606920431.jpg',
              fit: BoxFit.cover,
            ),
          ),
          
          // Dark overlay to ensure text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                  stops: const [0.0, 0.4, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // Scrollable content area (fills entire screen, goes under top and bottom)
          SafeArea(
            top: false,
            child: Column(
              children: [
                // Spacer for top blur area
                const SizedBox(height: 100),
                
                // Scrollable content
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      final messages = chatProvider.messages;

                      if (messages.isEmpty) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 0, bottom: 160),
                          child: EmptyState(
                            onExampleTap: (question) {
                              chatProvider.sendMessage(question);
                              _scrollToBottom();
                            },
                          ),
                        );
                      }

                      // Auto-scroll when messages change
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom();
                      });

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 160),
                        itemCount: messages.length + (chatProvider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            // Loading indicator with typing animation
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildLoadingDot(0),
                                        const SizedBox(width: 6),
                                        _buildLoadingDot(1),
                                        const SizedBox(width: 6),
                                        _buildLoadingDot(2),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return MessageBubble(
                            message: messages[index],
                            key: ValueKey(messages[index].id),
                            isLatest: index == messages.length - 1,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Top gradient overlay with blur (dark at edge, fades to light)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 120,
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
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Top content (AppBar) on top of blur
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Ayet Rehberi',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Kuran ayetlerine dayalı soru-cevap',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE8F5E9),
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        context.read<ChatProvider>().clearMessages();
                      },
                      tooltip: 'Yeni Sohbet',
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom gradient overlay with blur (light at middle, dark at edge)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.65),
                        ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom input bar (on top of gradient) - ChatGPT style
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, _) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF085A2D), // Daha koyu yeşil
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF7FE79C).withOpacity(0.6), // Light green stroke
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Microphone icon (for future voice input)
                        Icon(
                          Icons.mic_none,
                          color: Colors.white.withOpacity(0.85),
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        
                        // Text field
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            decoration: InputDecoration(
                              hintText: 'Kuran hakkında bir soru sorun...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.75),
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
                            textCapitalization: TextCapitalization.sentences,
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
                        
                        // Send button (white circle with upward arrow)
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
                            decoration: const BoxDecoration(
                              color: Colors.white,
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
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1400),
      builder: (context, value, child) {
        // Create a smooth wave effect with delay
        final phase = (value * 2 * math.pi) + (index * 0.4);
        final offset = (1 + (0.5 * (1 + math.sin(phase.abs() % (2 * math.pi)))));
        final opacity = 0.4 + (0.3 * (1 + math.sin(phase.abs() % (2 * math.pi))));
        
        return Transform.translate(
          offset: Offset(0, -offset * 3),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: const Color(0xFF22c55e).withOpacity(opacity),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22c55e).withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}


