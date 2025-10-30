import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/input_field.dart';
import '../theme/app_theme.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _initializeProvider();
  }

  void _initializeProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.initialize();

      // Check backend health
      final isHealthy = await chatProvider.checkBackendHealth();
      if (!isHealthy && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ Backend server may not be running. Please start the backend.',
            ),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      if (chatProvider.messages.isEmpty) {
        chatProvider.addBotMessage(
          "Welcome to Text Toner! 🎨\n\nI'm here to help you improve your text by adjusting tone, enhancing clarity, and making it more engaging. Just share your text and tell me what you'd like to improve!",
        );
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Custom App Bar with gradient
              _buildAppBar(),

              // Chat messages area
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    // Scroll to bottom when new messages are added
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount:
                          chatProvider.messages.length +
                          (chatProvider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < chatProvider.messages.length) {
                          final message = chatProvider.messages[index];
                          return MessageBubble(
                            message: message,
                            showAvatar: _shouldShowAvatar(
                              chatProvider.messages,
                              index,
                            ),
                          );
                        } else {
                          // Typing indicator
                          return MessageBubble(
                            message: Message(
                              id: 'typing',
                              text: '',
                              type: MessageType.typing,
                              timestamp: DateTime.now(),
                              isTyping: true,
                            ),
                            showAvatar: true,
                          );
                        }
                      },
                    );
                  },
                ),
              ),

              // Input field
              Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return ChatInputField(
                    onSendMessage: (text, {String? targetTone}) async {
                      final error = await chatProvider.sendMessageToBackend(
                        text,
                        context: targetTone,
                      );
                      if (error != null && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    onVoiceInput: () {
                      // TODO: Implement voice input functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice input coming soon!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    isLoading: chatProvider.isTyping,
                  );
                },
              ),
            ],
          ),
          if (_showHistory) _buildHistoryBackdrop(),
          _buildHistoryPanel(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.appBarGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Menu button (for future use)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showHistory = !_showHistory;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  // Title and tagline
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Text Toner',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tone your text, instantly',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spacer to keep layout symmetrical after removing settings
                  const SizedBox(width: 40, height: 40),
                ],
              ),

              const SizedBox(height: 16),

              // Quick action chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildQuickActionChip('Make it formal', Icons.business),
                    const SizedBox(width: 8),
                    _buildQuickActionChip('Add clarity', Icons.text_snippet),
                    const SizedBox(width: 8),
                    _buildQuickActionChip('Improve tone', Icons.tune),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () async {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        // Map quick actions to contexts
        String? contextValue;
        if (label == 'Make it formal') {
          contextValue = 'formal';
        } else if (label == 'Add clarity') {
          contextValue = 'professional';
        } else if (label == 'Improve tone') {
          contextValue = 'positive';
        }

        final error = await chatProvider.sendMessageToBackend(
          label,
          context: contextValue,
        );
        if (error != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowAvatar(List<Message> messages, int index) {
    if (index == 0) return true;

    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    // Show avatar if message type changed or if more than 2 minutes passed
    if (currentMessage.type != previousMessage.type) return true;

    final timeDifference = currentMessage.timestamp.difference(
      previousMessage.timestamp,
    );
    if (timeDifference.inMinutes > 2) return true;

    return false;
  }

  Widget _buildHistoryBackdrop() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showHistory = false;
          });
        },
        child: Container(color: Colors.black.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    const panelWidth = 260.0;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: _showHistory ? 0 : -panelWidth,
      width: panelWidth,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(2, 0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 18, color: Colors.black87),
                    SizedBox(width: 8),
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    final entries =
                        chatProvider.messages
                            .where((m) => m.type == MessageType.user)
                            .toList()
                            .reversed
                            .toList();
                    if (entries.isEmpty) {
                      return const Center(
                        child: Text(
                          'No history yet',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = entries[index];
                        final preview = item.text.trim();
                        return ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            preview.isEmpty ? '(empty)' : preview,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          onTap: () {
                            // Close panel on tap; future: could load past conversation state
                            setState(() {
                              _showHistory = false;
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
