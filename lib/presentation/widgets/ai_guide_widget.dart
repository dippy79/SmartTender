import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../models/chat_message.dart';
import 'ai_guide/_ai_bubble.dart';
import 'ai_guide/_ai_chat_bubble.dart';

class AiGuideWidget extends StatefulWidget {
  final String screenContext;
  final String? tenderId;
  const AiGuideWidget({
    super.key,
    required this.screenContext,
    this.tenderId,
  });

  @override
  State<AiGuideWidget> createState() => _AiGuideWidgetState();
}

class _AiGuideWidgetState extends State<AiGuideWidget> with TickerProviderStateMixin {
  bool _expanded = false;
  bool _loading = false;
  OverlayEntry? _overlayEntry;
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  late AnimationController _scaleCtrl;
  late AnimationController _opacityCtrl;
  int _tipIndex = 0;

  static const Map<String, String> _tips = {
    '/dashboard': 'See all active tenders, won bids, and pending BOQs at a glance.',
    '/tenders': 'Filter by category, deadline, or value. Tap any row for full details.',
    '/boq': '4-step wizard that auto-fills live commodity rates for accurate bidding.',
    '/commodities': 'Tap any commodity card to see its 7-day price trend chart.',
    '/history': 'Filter past bids by Won, Lost, Draft, or Submitted status.',
    '/ai': 'Ask Gemini anything: tendering law, GST rules, BOQ strategy.',
    '/admin': 'Manage users, update commodity rates, view platform analytics.',
    '/import': 'Upload Excel with tender data. Preview, validate, then save or share.',
  };



  @override
  void initState() {
    super.initState();

    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _opacityCtrl = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _insertOverlay());
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _opacityCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _insertOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: _buildOverlayContent(),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildOverlayContent() {
    return GestureDetector(
      onTap: () => setState(() => _expanded = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _expanded
            ? SizedBox(
                width: 320,
                child: Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: _AiCard(
                    tipIndex: _tipIndex,
                    messages: _messages,
                    loading: _loading,
                    inputCtrl: _inputCtrl,
                    scrollCtrl: _scrollCtrl,
                    onClose: () => setState(() => _expanded = false),
                    onSend: _send,
                    onPrev: _prevTip,
                    onNext: _nextTip,
                  ),
                ),
              )
            : AiBubble(
                onTap: () => setState(() => _expanded = true),
                isExpanded: false,
              ),
      ),
    );
  }

  String _buildPrompt(String userInput) => '''
You are SmartTender AI — expert assistant for Indian construction and engineering tender management.
Current screen: ${_tips[widget.screenContext] ?? 'General'}
${widget.tenderId != null ? 'Tender ID in context: ${widget.tenderId}' : ''}
User question: $userInput
Rules: Answer in max 3 sentences. Use ₹ for currency. Reference Indian tendering norms (GeM, CPWD, GFR) where relevant. Be direct and practical.
''';

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _loading = true;
    });
    _scrollToBottom();
    try {
      if (AppConfig.geminiApiKey.isEmpty) throw Exception('Gemini API key not configured');
      final model = GenerativeModel(model: 'gemini-pro', apiKey: AppConfig.geminiApiKey);
      final response = await model.generateContent([Content.text(_buildPrompt(text))]);
      setState(() {
        _messages.add(ChatMessage(text: response.text ?? 'No response', isUser: false));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: '⚠ Error: ${e.toString()}', isUser: false));
      });
    } finally {
      setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _prevTip() => setState(() => _tipIndex--);
  void _nextTip() => setState(() => _tipIndex++);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _AiCard extends StatelessWidget {
  final int tipIndex;
  final List<ChatMessage> messages;
  final bool loading;
  final TextEditingController inputCtrl;
  final ScrollController scrollCtrl;
  final VoidCallback onClose;
  final VoidCallback onSend;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  static const Map<String, String> _tips = _AiGuideWidgetState._tips;

  const _AiCard({
    required this.tipIndex,
    required this.messages,
    required this.loading,
    required this.inputCtrl,
    required this.scrollCtrl,
    required this.onClose,
    required this.onSend,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 420),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border.all(color: AppTheme.borderGold, width: 1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
color: Colors.black.withValues(alpha: 0.54),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '✨ AI Guide',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          // Tip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _tips.values.toList()[tipIndex % _tips.values.length],
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Nav
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_left, size: 16),
                  label: Text('Prev', style: GoogleFonts.dmSans(fontSize: 12)),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_right, size: 16),
                  label: Text('Next', style: GoogleFonts.dmSans(fontSize: 12)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.borderSubtle),
          // Chat area
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length + (loading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && loading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ),
                  );
                }
                return AiChatBubble(message: messages[index]);
              },
            ),
          ),
          // Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputCtrl,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      hintStyle: GoogleFonts.dmSans(color: AppTheme.textDim),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: AppTheme.borderSubtle),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: AppTheme.goldPrimary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onSend,
                  icon: Icon(Icons.send_rounded, color: AppTheme.goldPrimary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.goldSubtle,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

