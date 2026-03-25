import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/ai_guide_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.backgroundDeep,
      body: Stack(
        children: [
          Row(
            children: [
              AppSidebar(currentRoute: '/dashboard'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(auth),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          AiGuideWidget(screenContext: '/dashboard'),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(AuthProvider auth) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
     gradient: LinearGradient(
        colors: [
          AppTheme.accentBlue.withValues(alpha: 0.15),
          AppTheme.accentPurple.withValues(alpha: 0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.borderSubtle),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back 👋',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppTheme.textMuted)),
              const SizedBox(height: 4),
              Text('SmartTender Hub',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 28, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Manage tenders, BOQs and AI insights in one place.',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
Icon(Icons.trending_up_rounded, color: AppTheme.goldPrimary.withValues(alpha: 0.3))
      ],
    ),
  );

  Widget _buildStatsRow() => Row(
    children: [
      _statCard('Active Tenders', '24', Icons.description_outlined, AppTheme.accentBlue),
      const SizedBox(width: 12),
      _statCard('Won Bids', '8', Icons.emoji_events_outlined, AppTheme.accentGreen),
      const SizedBox(width: 12),
      _statCard('Pending BOQs', '5', Icons.hourglass_empty_rounded, AppTheme.goldPrimary),
      const SizedBox(width: 12),
      _statCard('Saved Tenders', '12', Icons.bookmark_outline_rounded, AppTheme.accentPurple),
    ],
  );

  Widget _statCard(String label, String value, IconData icon, Color color) =>
    Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.dmMono(
                        fontSize: 22, fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildQuickActions(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Quick Actions',
          style: GoogleFonts.playfairDisplay(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
      const SizedBox(height: 12),
      Row(
        children: [
          _actionCard(context, Icons.calculate_outlined, 'New BOQ',
              AppTheme.accentGreen, '/boq'),
          const SizedBox(width: 12),
          _actionCard(context, Icons.search_rounded, 'Browse Tenders',
              AppTheme.accentBlue, '/tenders'),
          const SizedBox(width: 12),
          _actionCard(context, Icons.auto_awesome_rounded, 'AI Advisor',
              AppTheme.accentPurple, '/ai'),
          const SizedBox(width: 12),
          _actionCard(context, Icons.history_rounded, 'Bid History',
              AppTheme.accentRed, '/history'),
        ],
      ),
    ],
  );

  Widget _actionCard(BuildContext context, IconData icon, String label,
      Color color, String route) =>
    Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );

  Widget _buildRecentActivity() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Recent Activity',
          style: GoogleFonts.playfairDisplay(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary)),
      const SizedBox(height: 12),
      Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            _activityItem(Icons.check_circle_outline_rounded,
                'BOQ submitted for Road Project', '2h ago', AppTheme.accentGreen),
            Divider(height: 1, color: AppTheme.borderSubtle),
            _activityItem(Icons.warning_amber_rounded,
                'Tender #ABC123 deadline approaching', '1 day ago', AppTheme.goldPrimary),
            Divider(height: 1, color: AppTheme.borderSubtle),
            _activityItem(Icons.auto_awesome_rounded,
                'AI analysis complete for Steel rates', '3 days ago', AppTheme.accentPurple),
          ],
        ),
      ),
    ],
  );

  Widget _activityItem(IconData icon, String title, String time, Color color) =>
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppTheme.textPrimary)),
          ),
          Text(time,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
}
