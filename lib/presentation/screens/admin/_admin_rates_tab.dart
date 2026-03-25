import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';

class AdminRatesTab extends StatefulWidget {
  const AdminRatesTab({super.key});

  @override
  State<AdminRatesTab> createState() => _AdminRatesTabState();
}

class _AdminRatesTabState extends State<AdminRatesTab> {
  List<Map<String, dynamic>> _rates = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  // Edit state
  String? _editingId;
  final _priceCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRates() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await Supabase.instance.client
          .from('commodity_rates')
          .select('id, name, unit, price_per_unit, updated_at')
          .order('name', ascending: true);
      if (mounted) {
        setState(() => _rates = List<Map<String, dynamic>>.from(res));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveRate(String id) async {
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client
          .from('commodity_rates')
          .update({'price_per_unit': price,
                   'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      await _loadRates();
      setState(() => _editingId = null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save: $e',
              style: GoogleFonts.dmSans(color: AppTheme.textPrimary)),
          backgroundColor: AppTheme.accentRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.isEmpty) return _rates;
    final q = _search.toLowerCase();
    return _rates.where((r) =>
        (r['name'] ?? '').toLowerCase().contains(q)).toList();
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
          child: _filtered.isEmpty ? _buildEmpty() : _buildTable(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() => TextField(
    onChanged: (v) => setState(() => _search = v),
    style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textPrimary),
    decoration: InputDecoration(
      hintText: 'Search commodities...',
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.textMuted),
      prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
      filled: true,
      fillColor: AppTheme.surfaceElevated,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.borderSubtle)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.borderSubtle)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppTheme.goldPrimary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  Widget _buildTable() => Container(
    decoration: AppTheme.cardDecoration,
    child: Column(
      children: [
        _RatesTableHeader(),
        Divider(height: 1, color: AppTheme.borderSubtle),
        Expanded(
          child: ListView.separated(
            itemCount: _filtered.length,
            separatorBuilder: (context, _) =>
                Divider(height: 1, color: AppTheme.borderSubtle),
            itemBuilder: (_, i) {
              final rate = _filtered[i];
              final isEditing = _editingId == rate['id'];
              if (isEditing) {
                return _EditRateRow(
                  rate: rate,
                  ctrl: _priceCtrl,
                  saving: _saving,
                  onSave: () => _saveRate(rate['id']),
                  onCancel: () => setState(() => _editingId = null),
                );
              }
              return _RateRow(
                rate: rate,
                onEdit: () {
                  _priceCtrl.text =
                      rate['price_per_unit']?.toString() ?? '';
                  setState(() => _editingId = rate['id']);
                },
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildSkeleton() => TweenAnimationBuilder<double>(
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

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.bar_chart_rounded, size: 48, color: AppTheme.textDim),
        const SizedBox(height: 12),
        Text('No rates found',
            style: GoogleFonts.playfairDisplay(
                fontSize: 22, color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Text('Try adjusting your search',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
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
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadRates,
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

// ── Table Header ──────────────────────────────────────────────────────────────

class _RatesTableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Expanded(flex: 3, child: _h('Commodity')),
        Expanded(flex: 2, child: _h('Unit')),
        Expanded(flex: 2, child: _h('Price (₹)')),
        Expanded(flex: 2, child: _h('Updated')),
        const SizedBox(width: 40),
      ],
    ),
  );

  Widget _h(String label) => Text(label.toUpperCase(),
    style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700,
        color: AppTheme.textDim, letterSpacing: 1.0));
}

// ── Rate Row ──────────────────────────────────────────────────────────────────

class _RateRow extends StatelessWidget {
  final Map<String, dynamic> rate;
  final VoidCallback onEdit;
  const _RateRow({required this.rate, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final updated = rate['updated_at'] != null
        ? rate['updated_at'].toString().substring(0, 10) : '—';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(rate['name'] ?? '—',
            style: GoogleFonts.dmSans(fontSize: 13,
                fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
          Expanded(flex: 2, child: Text(rate['unit'] ?? '—',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary))),
          Expanded(flex: 2, child: Text(
            '₹${rate['price_per_unit']?.toString() ?? '—'}',
            style: GoogleFonts.dmMono(fontSize: 13, color: AppTheme.goldPrimary))),
          Expanded(flex: 2, child: Text(updated,
            style: GoogleFonts.dmMono(fontSize: 12, color: AppTheme.textMuted))),
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 16, color: AppTheme.textMuted),
              tooltip: 'Edit rate',
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit Rate Row ─────────────────────────────────────────────────────────────

class _EditRateRow extends StatelessWidget {
  final Map<String, dynamic> rate;
  final TextEditingController ctrl;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _EditRateRow({
    required this.rate,
    required this.ctrl,
    required this.saving,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.goldSubtle,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(rate['name'] ?? '—',
            style: GoogleFonts.dmSans(fontSize: 13,
                fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
          Expanded(flex: 2, child: Text(rate['unit'] ?? '—',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textSecondary))),
          Expanded(flex: 2, child: SizedBox(
            height: 36,
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.dmMono(fontSize: 13, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: GoogleFonts.dmMono(
                    fontSize: 13, color: AppTheme.goldPrimary),
                filled: true,
                fillColor: AppTheme.surfaceElevated,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.borderGold)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
              ),
            ),
          )),
          const Expanded(flex: 2, child: SizedBox()),
          SizedBox(
            width: 40,
            child: saving
                ? SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.goldPrimary))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(onPressed: onSave,
                          icon: Icon(Icons.check_rounded,
                              size: 16, color: AppTheme.accentGreen)),
                      IconButton(onPressed: onCancel,
                          icon: Icon(Icons.close_rounded,
                              size: 16, color: AppTheme.accentRed)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}