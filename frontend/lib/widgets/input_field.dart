import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ChatInputField extends StatefulWidget {
  const ChatInputField({
    super.key,
    required this.onSendMessage,
    this.onVoiceInput,
    this.isLoading = false,
  });
  final Function(String, {String? targetTone}) onSendMessage;
  final Function()? onVoiceInput;
  final bool isLoading;

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _sendButtonAnimationController;
  late AnimationController _micButtonAnimationController;
  late Animation<double> _sendButtonScaleAnimation;
  late Animation<double> _micButtonScaleAnimation;

  String? _selectedTargetTone;
  bool _showToneSelector = false;

  // These will be populated from backend's supported tones
  // Fallback list if backend is unavailable
  final List<String> _targetTones = [
    'formal',
    'casual',
    'professional',
    'friendly',
    'persuasive',
    'inspirational',
    'empathetic',
    'authoritative',
    'enthusiastic',
    'neutral',
  ];

  @override
  void initState() {
    super.initState();

    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _micButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _sendButtonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _sendButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _micButtonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _micButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _sendButtonAnimationController.dispose();
    _micButtonAnimationController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(text, targetTone: _selectedTargetTone);
      _controller.clear();
    }
  }

  void _handleVoiceInput() {
    if (widget.onVoiceInput != null) {
      widget.onVoiceInput!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Target tone selector
            if (_showToneSelector) _buildToneSelector(),
            if (_showToneSelector) const SizedBox(height: 12),
            Row(
              children: [
                // Voice input button
                if (widget.onVoiceInput != null)
                  AnimatedBuilder(
                    animation: _micButtonScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _micButtonScaleAnimation.value,
                        child: GestureDetector(
                          onTapDown:
                              (_) => _micButtonAnimationController.forward(),
                          onTapUp: (_) {
                            _micButtonAnimationController.reverse();
                            _handleVoiceInput();
                          },
                          onTapCancel:
                              () => _micButtonAnimationController.reverse(),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.softPurple,
                                  AppTheme.lightBlue,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.softPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                if (widget.onVoiceInput != null) const SizedBox(width: 12),

                // Tone selector toggle button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showToneSelector = !_showToneSelector;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          _showToneSelector
                              ? AppTheme.primaryBlue
                              : AppTheme.inputFieldBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            _showToneSelector
                                ? AppTheme.primaryBlue
                                : AppTheme.inputFieldBorder,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.tune,
                      color:
                          _showToneSelector ? Colors.white : AppTheme.textGrey,
                      size: 18,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Text input field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.inputFieldBg,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppTheme.inputFieldBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !widget.isLoading,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppTheme.textGrey.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: AppTheme.darkGrey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Send button
                AnimatedBuilder(
                  animation: _sendButtonScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _sendButtonScaleAnimation.value,
                      child: GestureDetector(
                        onTapDown:
                            (_) => _sendButtonAnimationController.forward(),
                        onTapUp: (_) {
                          _sendButtonAnimationController.reverse();
                          _handleSendMessage();
                        },
                        onTapCancel:
                            () => _sendButtonAnimationController.reverse(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient:
                                widget.isLoading
                                    ? LinearGradient(
                                      colors: [
                                        AppTheme.textGrey.withOpacity(0.5),
                                        AppTheme.textGrey.withOpacity(0.3),
                                      ],
                                    )
                                    : AppTheme.sendButtonGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.isLoading
                                        ? AppTheme.textGrey
                                        : AppTheme.primaryBlue)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child:
                              widget.isLoading
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToneSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.inputFieldBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.inputFieldBorder, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, size: 16, color: AppTheme.textGrey),
          const SizedBox(width: 8),
          Text(
            'Target tone: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppTheme.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToneChip('None', null),
                  const SizedBox(width: 8),
                  ..._targetTones.map(
                    (tone) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildToneChip(tone, tone),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showToneSelector = false;
              });
            },
            child: const Icon(Icons.close, size: 16, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildToneChip(String label, String? value) {
    final isSelected = _selectedTargetTone == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTargetTone = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? AppTheme.primaryBlue : AppTheme.inputFieldBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isSelected ? Colors.white : AppTheme.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
