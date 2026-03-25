import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/excel_import_service.dart';
import '../../../models/tender_import_model.dart';
import '../../../presentation/widgets/ai_guide_widget.dart';
import '../../../presentation/widgets/import_step_indicator.dart';
import '../../../presentation/widgets/app_sidebar.dart';
import '_step3_export.dart';

class TenderImportScreen extends StatefulWidget {
  const TenderImportScreen({super.key});

  @override
  State<TenderImportScreen> createState() => _TenderImportScreenState();
}

class _TenderImportScreenState extends State<TenderImportScreen> {
  int _step = 0;
  List<TenderImportRow> _rows = [];
  bool _loading = false;
  String? _error;
  Uint8List? _templateBytes;
  final Map<String, bool> _exportPrefs = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _generateTemplate();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _exportPrefs['database'] = prefs.getBool('export_database') ?? true;
      _exportPrefs['pdf'] = prefs.getBool('export_pdf') ?? true;
      _exportPrefs['excel'] = prefs.getBool('export_excel') ?? false;
      _exportPrefs['whatsapp'] = prefs.getBool('export_whatsapp') ?? false;
      _exportPrefs['email'] = prefs.getBool('export_email') ?? false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _generateTemplate() async {
    _templateBytes = ExcelImportService.generateTemplate();
  }

  Future<void> _pickFile() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final rows = ExcelImportService.parseExcel(bytes);
        if (!mounted) return;
        setState(() {
          _rows = rows;
          _step = 1;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error reading file: $e';
        _loading = false;
      });
    }
  }

  int get _validCount => _rows.where((r) => r.validationError == null).length;

  void _nextStep() {
    if (_step == 1 && _validCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text('No valid rows found. Fix errors and try again.'),
        ),
      );
      return;
    }
    setState(() => _step++);
  }

  void _prevStep() => setState(() => _step--);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDeep,
      body: Row(
        children: [
          AppSidebar(currentRoute: '/import'),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.borderSubtle),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Excel Import',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Upload, validate, and export tenders in bulk',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error_outline, size: 64, color: AppTheme.accentRed),
                                  const SizedBox(height: 16),
                                  Text(_error!, style: GoogleFonts.playfairDisplay(fontSize: 22, color: AppTheme.textPrimary)),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _pickFile,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            )
                          : _rows.isEmpty
                              ? _Step1Upload(onPick: _pickFile, templateBytes: _templateBytes)
                                  : _step == 1
                                  ? _Step2Preview(rows: _rows, onNext: _nextStep, onBack: _prevStep)
                                  : Step3Export(
                                      rows: _rows,
                                      exportPrefs: _exportPrefs,
                                      onTogglePref: _savePref,
                                      onPrevious: _prevStep,
                                      onComplete: () {},
                                    ),
                ),
                // Step indicator
                Container(
                  padding: const EdgeInsets.all(24),
                  color: AppTheme.surfaceDark,
                  child: ImportStepIndicator(currentStep: _step),
                ),
              ],
            ),
          ),
          AiGuideWidget(screenContext: '/import'),
        ],
      ),
    );
  }
}

class _Step1Upload extends StatelessWidget {
  final VoidCallback onPick;
  final Uint8List? templateBytes;

  const _Step1Upload({
    required this.onPick,
    this.templateBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.goldPrimary.withAlpha(77),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.upload_file_rounded,
              size: 64,
              color: AppTheme.goldPrimary.withAlpha(153),
            ),
            const SizedBox(height: 24),
            Text(
              'Drop Excel file here',
              style: GoogleFonts.playfairDisplay(fontSize: 24, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'or click to browse',
              style: GoogleFonts.dmSans(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 32),
            Text(
              'Accepted: .xlsx, .xls • Max 10 MB',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.folder_open),
              label: const Text('Browse Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            if (templateBytes != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  // Download template - web implementation
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Template'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Step2Preview extends StatelessWidget {
  final List<TenderImportRow> rows;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step2Preview({
    required this.rows,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final validCount = rows.where((r) => r.validationError == null).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              _statusChip('${rows.length} rows found', AppTheme.textMuted),
              _statusChip('$validCount valid', AppTheme.accentGreen),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios),
                label: const Text('Back'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: validCount > 0 ? onNext : null,
                icon: const Icon(Icons.arrow_forward_ios),
                label: Text('Continue with $validCount valid →'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppTheme.surfaceElevated),
                dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.hovered)
                    ? AppTheme.surfaceSlate
                    : null),
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Dept', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Deadline', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: rows.asMap().entries.map((entry) {
                  final index = entry.key;
                  final row = entry.value;
                  final isError = row.validationError != null;
                  return DataRow(
                    color: WidgetStateProperty.resolveWith<Color?>((states) => isError
                        ? AppTheme.accentRed.withValues(alpha: 0.08)
                        : null),
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(row.title, overflow: TextOverflow.ellipsis)),
                      DataCell(Text(row.department)),
                      DataCell(Text('₹${row.value.toStringAsFixed(0)}')),
                      DataCell(Text(DateFormat('dd/MM').format(row.deadline))),
                      DataCell(Text(row.status)),
                      DataCell(
                        Tooltip(
                          message: row.validationError ?? 'Valid',
                          decoration: BoxDecoration(
                            color: isError ? AppTheme.accentRed : Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            isError ? Icons.error_outline : Icons.check_circle,
                            color: isError ? AppTheme.accentRed : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
