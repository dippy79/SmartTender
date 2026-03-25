import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/ai_guide/_ai_quick_prompts.dart';
import '../../widgets/ai_guide/_ai_chat_view.dart';

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  String _pendingPrompt = '';
  String? _activeSessionId;
  int _chatKey = 0;

  void _onPromptSelected(String prompt) {
    setState(() => _pendingPrompt = prompt);
  }

  void _onNewChat() {
    setState(() {
      _pendingPrompt = '';
      _activeSessionId = null;
      _chatKey++;
    });
  }

  void _onSessionSaved(String id) {
    if (_activeSessionId == null) {
      setState(() => _activeSessionId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDeep,
      body: Row(
        children: [
          AppSidebar(currentRoute: '/ai'),
          SizedBox(
            width: 280,
            child: _PromptPanel(
              activeSessionId: _activeSessionId,
              onPromptSelected: _onPromptSelected,
              onNewChat: _onNewChat,
            ),
          ),
          Container(width: 1, color: AppTheme.borderSubtle),
          Expanded(
            child: AiChatView(
              key: ValueKey(_chatKey),
              initialPrompt: _pendingPrompt,
              sessionId: _activeSessionId,
              onNewChat: _onNewChat,
              onSessionSaved: _onSessionSaved,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptPanel extends StatelessWidget {
  final String? activeSessionId;
  final ValueChanged<String> onPromptSelected;
  final VoidCallback onNewChat;

  const _PromptPanel({
    required this.activeSessionId,
    required this.onPromptSelected,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            border: Border(
              bottom: BorderSide(color: AppTheme.borderSubtle),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppTheme.accentPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Advisor',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Tooltip(
                message: 'New chat',
                child: InkWell(
                  onTap: onNewChat,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.goldSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      size: 16,
                      color: AppTheme.goldPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AiQuickPrompts(
            onPromptSelected: onPromptSelected,
            activeSessionId: activeSessionId,
            onSessionSelected: (id) {},
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 12, color: AppTheme.textDim),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Powered by Gemini Pro',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppTheme.textDim,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}