import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/input_field.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ConversationDetailSheet extends StatelessWidget {
  const _ConversationDetailSheet({required this.detail});

  final ConversationDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enhanced = detail.enhancedVersions;
    final suggestions = detail.suggestions;
    final note = detail.analysis['note']?.toString();
    final service = detail.analysis['service']?.toString();
    final createdLabel = _formatTimestamp(detail.createdAt.toLocal());

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Conversation details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetadataChip(
                    label: 'Tone',
                    value:
                        detail.detectedTone != null &&
                                detail.detectedTone!.isNotEmpty
                            ? detail.detectedTone![0].toUpperCase() +
                                detail.detectedTone!.substring(1)
                            : 'Unknown',
                  ),
                  if (detail.confidence != null)
                    _MetadataChip(
                      label: 'Confidence',
                      value:
                          '${(detail.confidence! * 100).toStringAsFixed(0)}%',
                    ),
                  _MetadataChip(label: 'Created', value: createdLabel),
                  if (detail.context != null && detail.context!.isNotEmpty)
                    _MetadataChip(label: 'Context', value: detail.context!),
                ],
              ),
              const SizedBox(height: 24),
              _DetailSection(
                title: 'Original message',
                child: SelectableText(
                  detail.originalText.isEmpty
                      ? '(empty message)'
                      : detail.originalText,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (detail.explanation.isNotEmpty) ...[
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'Analysis',
                  child: Text(detail.explanation),
                ),
              ],
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'Suggestions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final suggestion in suggestions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• '),
                              Expanded(child: Text(suggestion)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (enhanced.isNotEmpty) ...[
                const SizedBox(height: 16),
                _DetailSection(
                  title: 'Enhanced versions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < enhanced.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _toneLabel(enhanced[i]['tone'], index: i + 1),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(enhanced[i]['text']?.toString() ?? ''),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 16),
                _DetailSection(title: 'Note', child: Text(note)),
              ],
              if (service != null && service.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Generated via $service',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final datePart =
        '${timestamp.month.toString().padLeft(2, '0')}/${timestamp.day.toString().padLeft(2, '0')}/${timestamp.year}';
    final hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final suffix = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$datePart $hour:$minute $suffix';
  }

  String _toneLabel(Object? tone, {required int index}) {
    final value = tone?.toString() ?? '';
    if (value.isEmpty) {
      return 'Option $index';
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
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
      await chatProvider.refreshConversationHistory(force: true);

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
                    onTap: () async {
                      final chatProvider = Provider.of<ChatProvider>(
                        context,
                        listen: false,
                      );
                      setState(() {
                        _showHistory = !_showHistory;
                      });
                      if (_showHistory) {
                        await chatProvider.refreshConversationHistory();
                      }
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

                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final displayName = auth.user?.displayName ?? 'User';
                      return PopupMenuButton<String>(
                        tooltip: 'Account menu',
                        onSelected: (value) {
                          if (value == 'logout') {
                            context.read<AuthProvider>().logout();
                          }
                        },
                        itemBuilder:
                            (context) => const [
                              PopupMenuItem<String>(
                                value: 'logout',
                                child: Text('Sign out'),
                              ),
                            ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                child: Text(
                                  _initials(displayName),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    final first = parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    final second =
        parts.length > 1 && parts[1].isNotEmpty
            ? parts[1][0].toUpperCase()
            : '';
    final initials = (first + second).trim();
    return initials.isEmpty ? parts.first[0].toUpperCase() : initials;
  }

  String _conversationSubtitle(ConversationSummary conversation) {
    final parts = <String>[];
    if (conversation.detectedTone != null &&
        conversation.detectedTone!.isNotEmpty) {
      var tone = _titleCase(conversation.detectedTone!);
      if (conversation.confidence != null) {
        tone = '$tone ${(conversation.confidence! * 100).toStringAsFixed(0)}%';
      }
      parts.add(tone);
    }
    parts.add(_formatTimestamp(conversation.createdAt));
    return parts.join(' • ');
  }

  String _formatTimestamp(DateTime timestamp) {
    final local = timestamp.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(local)}';
    }
    if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(local)}';
    }
    return '${local.month.toString().padLeft(2, '0')}/${local.day.toString().padLeft(2, '0')}/${local.year} ${_formatTime(local)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }

  Future<void> _openConversationDetail(ConversationSummary summary) async {
    final chatProvider = context.read<ChatProvider>();
    final detail = await chatProvider.loadConversationDetail(summary.id);
    if (!mounted) {
      return;
    }
    if (detail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load conversation details.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ConversationDetailSheet(detail: detail),
    );
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
                    final history = chatProvider.conversationHistory;

                    if (chatProvider.isHistoryLoading && history.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      );
                    }

                    if (history.isEmpty) {
                      return const Center(
                        child: Text(
                          'No saved conversations yet',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh:
                          () => chatProvider.refreshConversationHistory(
                            force: true,
                          ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: history.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final conversation = history[index];
                          final preview = conversation.originalText.trim();
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            title: Text(
                              preview.isEmpty ? '(empty message)' : preview,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              _conversationSubtitle(conversation),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            onTap: () async {
                              setState(() {
                                _showHistory = false;
                              });
                              await _openConversationDetail(conversation);
                            },
                          );
                        },
                      ),
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
