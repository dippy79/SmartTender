import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class AdminStatsRow extends StatelessWidget {
  final int totalUsers;
  final int activeTenders;
  final int totalOrgs;
  final int commodityRates;
  final bool loading;

  const AdminStatsRow({
    super.key,
    required this.totalUsers,
    required this.activeTenders,
    required this.totalOrgs,
    required this.commodityRates,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final stats = [
StatData(
        label: 'Total Users',
        value: totalUsers,
        icon: Icons.people_outline_rounded,
        color: AppTheme.accentBlue,
      ),
StatData(
        label: 'Active Tenders',
        value: activeTenders,
        icon: Icons.description_outlined,
        color: AppTheme.accentGreen,
      ),
StatData(
        label: 'Organisations',
        value: totalOrgs,
        icon: Icons.business_outlined,
        color: AppTheme.goldPrimary,
      ),
StatData(
        label: 'Commodity Rates',
        value: commodityRates,
        icon: Icons.bar_chart_rounded,
        color: AppTheme.accentPurple,
      ),
    ];

    return Row(
      children: stats
          .map((StatData s) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: loading
                      ? _SkeletonCard()
                      : _StatCard(data: s),
                ),
              ))
          .toList(),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, size: 20, color: data.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value.toString(),
                  style: GoogleFonts.dmMono(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textMuted,
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

// ── Skeleton Card ─────────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Opacity(
        opacity: _anim.value,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class StatData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}
