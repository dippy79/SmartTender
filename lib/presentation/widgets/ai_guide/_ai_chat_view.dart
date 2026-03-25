import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';

class AiChatView extends StatefulWidget {
  final String initialPrompt;
  final String? sessionId;
  final VoidCallback onNewChat;
  final ValueChanged<String> onSessionSaved;

  const AiChatView({
    super.key,
    this.initialPrompt = '',
    this.sessionId,
    required this.onNewChat,
    required this.onSessionSaved,
  });

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> with TickerProviderStateMixin {
  bool _loading = false;
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late AnimationController _dotCtrl;
  String? _currentSessionId;

  static const String _system = '''
You are SmartTender AI — expert for Indian construction tender management.
Cover: GeM, CPWD, NIC, eProcure portals. BOQ preparation. GST works contracts
(12% composite, 18% standard). GFR 2017. EMD and performance guarantee norms.
Bid strategy and margin optimization. Construction commodity price trends India.
Use ₹ for currency. Bullet points for lists. Bold key terms with **.
Max 200 words unless user explicitly asks for more detail.
''';

  @override
  void initState() {
    super.initState();
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    if (widget.initialPrompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(widget.initialPrompt));
    }
  }

  @override
  void didUpdateWidget(covariant AiChatView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPrompt != oldWidget.initialPrompt && widget.initialPrompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(widget.initialPrompt));
    }
  }

  @override
  void dispose() {
    _dotCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send([String? override]) async {
    final text = (override ?? _inputCtrl.text).trim();
    if (text.isEmpty || _loading) return;
    _inputCtrl.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _loading = true;
    });
    _scrollToBottom();
    try {
      if (AppConfig.geminiApiKey.isEmpty) throw Exception('Gemini API key not set in .env');
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: AppConfig.geminiApiKey,
        systemInstruction: Content.system(_system),
      );
      final history = _messages.length > 1
          ? _messages.sublist(0, _messages.length - 1)
              .map((m) => Content(m.isUser ? 'user' : 'model', [TextPart(m.text)]))
              .toList()
          : <Content>[];
      final chat = model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(text));
      setState(() => _messages.add(
            ChatMessage(text: response.text ?? 'No response', isUser: false)));
      await _saveSession();
    } catch (e) {
      setState(() => _messages.add(
            ChatMessage(text: '⚠ ${e.toString()}', isUser: false)));
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

  Future<void> _saveSession() async {
    if (_messages.isEmpty) return;
    final title = _messages.first.text.substring(
        0, _messages.first.text.length.clamp(0, 50));
    final content = _messages
        .map((m) => {'text': m.text, 'isUser': m.isUser})
        .toList()
        .toString();
    try {
      if (_currentSessionId == null) {
        final data = await Supabase.instance.client
            .from('knowledge_base')
            .insert({
              'title': title,
              'content': content,
              'created_at': DateTime.now().toIso8601String()
            })
            .select('id')
            .single();
        _currentSessionId = data['id'] as String;
        widget.onSessionSaved(_currentSessionId!);
      } else {
        await Supabase.instance.client
            .from('knowledge_base')
            .update({'content': content})
            .eq('id', _currentSessionId!);
      }
    } catch (_) {}
  }

  Widget _buildDots() => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) => AnimatedBuilder(
              animation: _dotCtrl,
              builder: (_, _) => Transform.translate(
                offset: Offset(
                    0, -4 * sin(_dotCtrl.value * 2 * pi + i * pi / 3)),
                child: Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                      color: AppTheme.accentPurple, shape: BoxShape.circle),
                ),
              ),
            )),
      );

  List<Widget> _buildMessageContent(String text) {
    final parts = text.split('```');
    return parts.asMap().entries.map((e) {
      if (e.key.isOdd) {
        // Code block
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border.all(color: AppTheme.borderSubtle),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(children: [
            Text(
              e.value.trim(),
              style:
                  GoogleFonts.dmMono(fontSize: 12, color: AppTheme.textSecondary),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.copy_rounded,
                    size: 13, color: AppTheme.textMuted),
                tooltip: 'Copy',
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: e.value.trim())),
              ),
            ),
          ]),
        );
      }
      // Plain text
      return Text(
        e.value,
        style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.6),
      );
    }).toList();
  }

  Widget _buildBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          margin: const EdgeInsets.only(bottom: 12, left: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.goldSubtle,
            border: Border.all(color: AppTheme.borderGold),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            msg.text,
            style:
                GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
          ),
        ),
      );
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.35)),
        ),
        child: const Icon(Icons.auto_awesome_rounded,
            color: AppTheme.accentPurple, size: 15),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, right: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            border: Border.all(color: AppTheme.borderSubtle),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildMessageContent(msg.text),
          ),
        ),
      ),
    ]);
  }

  Widget _buildHeader() => Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accentPurple.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
          ),
          child: const Icon(Icons.auto_awesome_rounded,
              color: AppTheme.accentPurple, size: 17),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Advisor',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          Text('Gemini Pro · Indian tendering expert',
              style:
                  GoogleFonts.dmSans(fontSize: 11, color: AppTheme.textMuted)),
        ]),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.refresh_rounded,
              size: 17, color: AppTheme.textMuted),
          tooltip: 'New conversation',
          onPressed: () {
            setState(() {
              _messages.clear();
              _currentSessionId = null;
            });
            widget.onNewChat();
          },
        ),
      ]);

  Widget _buildInputArea() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  maxLines: 4,
                  minLines: 1,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.dmSans(
                      fontSize: 14, color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText:
                        'Ask anything about tendering, BOQ, GST, rates...',
                    hintStyle: GoogleFonts.dmSans(
                        fontSize: 14, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppTheme.borderGold, width: 1.2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _loading ? null : _send,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  disabledBackgroundColor:
                      AppTheme.goldPrimary.withValues(alpha: 0.3),
                  foregroundColor: const Color(0xFF1A1000),
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Icon(Icons.send_rounded, size: 20),
              ),
            ]),
            const SizedBox(height: 6),
            Text(
              'Gemini Pro · Responses are AI-generated, not legal advice',
              style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppTheme.textDim),
            ),
          ],
        ),
      );

  Widget _buildWelcome() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppTheme.accentPurple, size: 28),
            ),
            const SizedBox(height: 16),
            Text('Ask SmartTender AI',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('Select a quick prompt or type your question',
                style:
                    GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
        ),
        child: _buildHeader(),
      ),
      Expanded(
        child: Container(
          color: AppTheme.backgroundDeep,
          child: _messages.isEmpty && !_loading
              ? _buildWelcome()
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length + (_loading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 42, bottom: 12),
                        child: _buildDots(),
                      );
                    }
                    return _buildBubble(_messages[i]);
                  },
                ),
        ),
      ),
      _buildInputArea(),
    ]);
  }
}

