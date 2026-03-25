import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class Step3Export extends StatelessWidget {
  final List<dynamic> rows;
  final Map<String, bool> exportPrefs;
  final Function(String, bool) onTogglePref;
  final VoidCallback onPrevious;
  final VoidCallback onComplete;

  const Step3Export({
    super.key,
    required this.rows,
    required this.exportPrefs,
    required this.onTogglePref,
    required this.onPrevious,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Export Options',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${rows.length} valid tenders ready',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CheckboxListTile(
                title: const Text('Save to Database'),
                value: exportPrefs['database'],
                onChanged: (v) => onTogglePref('database', v ?? false),
                activeColor: AppTheme.goldPrimary,
                checkColor: AppTheme.backgroundDeep,
              ),
              CheckboxListTile(
                title: const Text('Generate PDF'),
                value: exportPrefs['pdf'],
                onChanged: (v) => onTogglePref('pdf', v ?? false),
                activeColor: AppTheme.accentBlue,
                checkColor: AppTheme.backgroundDeep,
              ),
              CheckboxListTile(
                title: const Text('Excel Export'),
                value: exportPrefs['excel'],
                onChanged: (v) => onTogglePref('excel', v ?? false),
                activeColor: AppTheme.accentGreen,
                checkColor: AppTheme.backgroundDeep,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.goldSubtle),
                  foregroundColor: AppTheme.goldPrimary,
                ),
                child: const Text('Back'),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: AppTheme.backgroundDeep,
                ),
                child: const Text('Export Now'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
