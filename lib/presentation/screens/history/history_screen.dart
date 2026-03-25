import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_sidebar.dart';
import '../../widgets/ai_guide_widget.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _submissions = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  static const _filters = ['All', 'Won', 'Lost', 'Pending', 'Draft'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) { setState(() => _loading = false); return; }
      var query = Supabase.instance.client
          .from('boq_submissions')
          .select('id, tender_title, status, total_value, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      final res = await query;
      if (mounted) setState(() => _submissions = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return _submissions;
    return _submissions.where((s) => s['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDeep,
      body: Stack(
        children: [
          Row(
            children: [
              AppSidebar(currentRoute: '/history'),
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(),
                    _buildFilterBar(),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ],
          ),
          AiGuideWidget(screenContext: '/history'),
        ],
      ),
    );
  }

  Widget _buildHeader() => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: AppTheme.surfaceDark,
      border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
    ),
    child: Row(
      children: [
        Icon(Icons.history_rounded, size: 20, color: AppTheme.goldPrimary),
        const SizedBox(width: 12),
        Text('Bid History',
            style: GoogleFonts.playfairDisplay(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const Spacer(),
        IconButton(
          onPressed: _loadData,
          icon: Icon(Icons.refresh_rounded, color: AppTheme.goldPrimary, size: 18),
          tooltip: 'Refresh',
        ),
      ],
    ),
  );

  Widget _buildFilterBar() => Container(
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: AppTheme.surfaceDark,
      border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
    ),
    child: Row(
      children: _filters.map((f) {
        final active = _filter == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () { setState(() => _filter = f); _loadData(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? AppTheme.goldPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: active ? AppTheme.goldPrimary : AppTheme.borderSubtle),
              ),
              child: Text(f,
                style: GoogleFonts.dmSans(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: active ? const Color(0xFF1A1000) : AppTheme.textMuted)),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildBody() {
    if (_loading) return _buildSkeleton();
    if (_error != null) return _buildError();
    if (_filtered.isEmpty) return _buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _filtered.length,
      itemBuilder: (context, i) => _HistoryCard(item: _filtered[i]),
    );
  }

  Widget _buildSkeleton() => ListView.builder(
    padding: const EdgeInsets.all(24),
    itemCount: 5,
    itemBuilder: (context, i) => TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 800),
      builder: (context, val, _) => Opacity(
        opacity: val,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
  );

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.history_rounded, size: 64, color: AppTheme.textDim),
      const SizedBox(height: 16),
      Text('No submissions yet',
          style: GoogleFonts.playfairDisplay(
              fontSize: 22, color: AppTheme.textPrimary)),
      const SizedBox(height: 8),
      Text('Your BOQ submissions will appear here',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
    ]),
  );

  Widget _buildError() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.accentRed),
      const SizedBox(height: 12),
      Text(_error ?? 'Error loading data',
          style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: _loadData,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldPrimary,
          foregroundColor: const Color(0xFF1A1000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text('Retry', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HistoryCard({required this.item});

  Color _statusColor(String? status) {
    switch (status) {
      case 'Won': return AppTheme.goldPrimary;
      case 'Lost': return AppTheme.accentRed;
      case 'Pending': return AppTheme.accentBlue;
      default: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = item['status'] ?? 'Draft';
    final title = item['tender_title'] ?? 'Untitled';
    final value = item['total_value'];
    final date = item['created_at'] != null
        ? item['created_at'].toString().substring(0, 10) : '—';
    final color = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            width: 8, height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text(date,
                    style: GoogleFonts.dmMono(
                        fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (value != null)
            Text('₹${value.toString()}',
                style: GoogleFonts.dmMono(
                    fontSize: 13, fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
color: color.withValues(alpha: 0.12),            
 borderRadius: BorderRadius.circular(20),     
      border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(status.toUpperCase(),
                style: GoogleFonts.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: color, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}
