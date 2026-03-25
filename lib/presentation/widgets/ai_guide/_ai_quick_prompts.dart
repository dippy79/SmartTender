import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class AiQuickPrompts extends StatefulWidget {
  final ValueChanged<String> onPromptSelected;
  final String? activeSessionId;
  final ValueChanged<String> onSessionSelected;

  const AiQuickPrompts({
    super.key,
    required this.onPromptSelected,
    required this.activeSessionId,
    required this.onSessionSelected,
  });

  @override
  State<AiQuickPrompts> createState() => _AiQuickPromptsState();
}

class _AiQuickPromptsState extends State<AiQuickPrompts> {
  static const _prompts = [
    ('GeM Portal', 'How do I register on GeM portal for tender bidding?', Icons.store_outlined),
    ('BOQ Tips', 'What are best practices for BOQ preparation in CPWD tenders?', Icons.list_alt_outlined),
    ('EMD Norms', 'Explain EMD and performance guarantee norms for government tenders', Icons.account_balance_outlined),
    ('GST on Works', 'What is GST rate for works contracts — 12% vs 18% when?', Icons.receipt_long_outlined),
    ('Bid Strategy', 'How to price a bid competitively without losing margin?', Icons.trending_up_outlined),
    ('GFR 2017', 'Key procurement rules under GFR 2017 I must know', Icons.gavel_outlined),
    ('NIC eProcure', 'Step-by-step guide to submit bid on NIC eProcure portal', Icons.upload_outlined),
    ('Commodity Prices', 'Current steel, cement, sand prices affecting my BOQ costs?', Icons.bar_chart_outlined),
  ];

  List<Map<String, dynamic>> _recentChats = [];
  bool _loadingChats = false;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _loadRecentChats();
  }

  Future<void> _loadRecentChats() async {
    setState(() => _loadingChats = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final res = await Supabase.instance.client
          .from('knowledge_base')
          .select('id, title, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);
      if (mounted) setState(() => _recentChats = List<Map<String, dynamic>>.from(res));
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingChats = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        _sectionLabel('Quick Prompts'),
        const SizedBox(height: 6),
        ..._prompts.asMap().entries.map((e) => _PromptTile(
              index: e.key,
              icon: e.value.$3,
              label: e.value.$1,
              prompt: e.value.$2,
              isHovered: _hoveredIndex == e.key,
              isActive: false,
              onHover: (v) => setState(() => _hoveredIndex = v ? e.key : null),
              onTap: () => widget.onPromptSelected(e.value.$2),
            )),
        const SizedBox(height: 16),
        _sectionLabel('Recent Chats'),
        const SizedBox(height: 6),
        if (_loadingChats)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(
              backgroundColor: AppTheme.borderSubtle,
              color: AppTheme.accentPurple,
              minHeight: 2,
            ),
          )
        else if (_recentChats.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No recent chats yet',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.textDim),
            ),
          )
        else
          ..._recentChats.map((chat) => _RecentChatTile(
                title: chat['title'] ?? 'Untitled Chat',
                isActive: widget.activeSessionId == chat['id'],
                onTap: () => widget.onSessionSelected(chat['id']),
              )),
      ],
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDim,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ── Prompt tile ──────────────────────────────────────────────────────────────

class _PromptTile extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final String prompt;
  final bool isHovered;
  final bool isActive;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;

  const _PromptTile({
    required this.index,
    required this.icon,
    required this.label,
    required this.prompt,
    required this.isHovered,
    required this.isActive,
    required this.onHover,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = isActive || isHovered;
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: highlight
                ? AppTheme.accentPurple.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight
                  ? AppTheme.accentPurple.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 16,
                  color: highlight ? AppTheme.accentPurple : AppTheme.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: highlight ? AppTheme.textPrimary : AppTheme.textSecondary,
                  ),
                ),
              ),
              if (isHovered)
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 11, color: AppTheme.accentPurple),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent chat tile ─────────────────────────────────────────────────────────

class _RecentChatTile extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _RecentChatTile({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.goldSubtle : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AppTheme.borderGold : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 14,
                color: isActive ? AppTheme.goldPrimary : AppTheme.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: isActive ? AppTheme.goldPrimary : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}