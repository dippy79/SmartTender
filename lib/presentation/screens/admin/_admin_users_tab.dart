import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, email, active_business_type, created_at')
          .order('created_at', ascending: false);
      if (mounted) setState(() => _users = List<Map<String, dynamic>>.from(res));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _users;
    final q = _search.toLowerCase();
    return _users.where((u) =>
      (u['full_name'] ?? '').toLowerCase().contains(q) ||
      (u['email'] ?? '').toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildSkeleton();
    if (_error != null) return _buildError();
    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 16),
        Expanded(
          child: _filtered.isEmpty
              ? _buildEmpty()
              : _buildTable(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => _search = v),
      style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search users by name or email...',
        hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
        prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
        filled: true,
        fillColor: AppTheme.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.goldPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        children: [
          _TableHeader(),
          const Divider(height: 1, color: AppTheme.borderSubtle),
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (context, _) =>
                  const Divider(height: 1, color: AppTheme.borderSubtle),
              itemBuilder: (_, i) => _UserRow(user: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 800),
      builder: (context, val, _) => Opacity(
        opacity: val,
        child: Column(
          children: List.generate(5, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(8),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.people_outline_rounded, size: 48, color: AppTheme.textDim),
        const SizedBox(height: 12),
        Text('No users found',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text('Try adjusting your search',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppTheme.textMuted)),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_off_rounded, size: 48, color: AppTheme.accentRed),
        const SizedBox(height: 12),
        Text(_error ?? 'Something went wrong',
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppTheme.textMuted)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadUsers,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.goldPrimary,
            foregroundColor: const Color(0xFF1A1000),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Retry',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

// ── Table Header ─────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerCell('Name')),
          Expanded(flex: 3, child: _headerCell('Email')),
          Expanded(flex: 2, child: _headerCell('Business Type')),
          Expanded(flex: 2, child: _headerCell('Joined')),
        ],
      ),
    );
  }

  Widget _headerCell(String label) => Text(
    label.toUpperCase(),
    style: GoogleFonts.dmSans(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: AppTheme.textDim,
      letterSpacing: 1.0,
    ),
  );
}

// ── User Row ─────────────────────────────────────────────────────────────────

class _UserRow extends StatelessWidget {
  final Map<String, dynamic> user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] ?? 'Unknown';
    final email = user['email'] ?? '—';
    final biz = user['active_business_type'] ?? '—';
    final joined = user['created_at'] != null
        ? user['created_at'].toString().substring(0, 10)
        : '—';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentBlue,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          )),
          Expanded(flex: 3, child: Text(email,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppTheme.textSecondary))),
          Expanded(flex: 2, child: _BizPill(label: biz)),
          Expanded(flex: 2, child: Text(joined,
            style: GoogleFonts.dmMono(
                fontSize: 12, color: AppTheme.textMuted))),
        ],
      ),
    );
  }
}

// ── Business Type Pill ────────────────────────────────────────────────────────

class _BizPill extends StatelessWidget {
  final String label;
  const _BizPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.accentGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.accentGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}