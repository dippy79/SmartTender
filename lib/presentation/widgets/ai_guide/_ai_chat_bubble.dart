import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/chat_message.dart';

class AiChatBubble extends StatelessWidget {
  final ChatMessage message;

  const AiChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUserMsg = message.isUser;
    return Align(
      alignment: isUserMsg ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUserMsg ? AppTheme.goldSubtle : AppTheme.surfaceDark,
          border: Border.all(
            color: isUserMsg ? AppTheme.borderGold : AppTheme.borderSubtle,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isUserMsg ? 12 : 0),
            topRight: Radius.circular(isUserMsg ? 0 : 12),
            bottomLeft: const Radius.circular(12),
            bottomRight: const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: GoogleFonts.dmMono(
                fontSize: 9,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inMinutes < 1) return 'Just now';
    if (now.difference(time).inHours < 1) return '${now.difference(time).inMinutes}m ago';
    return '${now.difference(time).inHours}h ago';
  }
}
