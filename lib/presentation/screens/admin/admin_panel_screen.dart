import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/ai_guide_widget.dart';
import '_admin_stats_row.dart';
import '_admin_users_tab.dart';
import '_admin_rates_tab.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Stats
  int _totalUsers = 0;
  int _activeTenders = 0;
  int _totalOrgs = 0;
  int _commodityRates = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    try {
      final db = Supabase.instance.client;
      final results = await Future.wait([
        db.from('profiles').select('id', ).count(),
        db.from('tenders').select('id').eq('status', 'Open').count(),
        db.from('organizations').select('id').count(),
        db.from('commodity_rates').select('id').count(),
      ]);
      if (mounted) {
        setState(() {
          _totalUsers     = results[0].count;
          _activeTenders  = results[1].count;
          _totalOrgs      = results[2].count;
          _commodityRates = results[3].count;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDeep,
      body: Stack(
        children: [
          Row(
            children: [
              AppSidebar(currentRoute: '/admin'),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats row
                            AdminStatsRow(
                              totalUsers: _totalUsers,
                              activeTenders: _activeTenders,
                              totalOrgs: _totalOrgs,
                              commodityRates: _commodityRates,
                              loading: _statsLoading,
                            ),
                            const SizedBox(height: 24),

                            // Tab bar
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceDark,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.borderSubtle),
                              ),
                              child: TabBar(
                                controller: _tabCtrl,
                                padding: const EdgeInsets.all(4),
                                indicator: BoxDecoration(
                                  color: AppTheme.goldPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                indicatorSize: TabBarIndicatorSize.tab,
                                labelColor: const Color(0xFF1A1000),
                                unselectedLabelColor: AppTheme.textMuted,
                                labelStyle: GoogleFonts.dmSans(
                                    fontSize: 13, fontWeight: FontWeight.w600),
                                unselectedLabelStyle:
                                    GoogleFonts.dmSans(fontSize: 13),
                                dividerColor: Colors.transparent,
                                tabs: const [
                                  Tab(text: 'Users'),
                                  Tab(text: 'Commodity Rates'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Tab content
                            SizedBox(
                              height: 520,
                              child: TabBarView(
                                controller: _tabCtrl,
                                children: const [
                                  AdminUsersTab(),
                                  AdminRatesTab(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AiGuideWidget(screenContext: '/admin'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined,
              size: 20, color: AppTheme.goldPrimary),
          const SizedBox(width: 12),
          Text('Admin Panel',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const Spacer(),
          // Refresh stats button
          Tooltip(
            message: 'Refresh stats',
            child: InkWell(
              onTap: _loadStats,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.goldSubtle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.refresh_rounded,
                    size: 16, color: AppTheme.goldPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
    }