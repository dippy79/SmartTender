import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class ImportStepIndicator extends StatelessWidget {
  final int currentStep;
  static const List<String> steps = ['Upload', 'Preview & Validate', 'Export'];

  const ImportStepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step circles and connectors
        Row(
          children: List.generate(3, (index) => Expanded(
            child: CustomPaint(
              size: const Size(40, 4),
              painter: StepConnectorPainter(
                isCompleted: index < currentStep,
              ),
            ),
          )),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) => _StepCircle(
            index: index,
            isCurrent: index == currentStep,
            isCompleted: index < currentStep,
          )),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final stepName = entry.value;
            Color textColor;
            if (index < currentStep) {
              textColor = AppTheme.accentGreen;
            } else if (index == currentStep) {
              textColor = AppTheme.goldPrimary;
            } else {
              textColor = AppTheme.textMuted;
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                stepName,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: index <= currentStep ? FontWeight.w600 : FontWeight.normal,
                  color: textColor,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isCurrent;
  final bool isCompleted;

  const _StepCircle({
    required this.index,
    required this.isCurrent,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Widget child;

    if (isCompleted) {
      bgColor = AppTheme.accentGreen;
      borderColor = AppTheme.accentGreen;
      child = const Icon(Icons.check, size: 16, color: Colors.white);
    } else if (isCurrent) {
      bgColor = AppTheme.goldPrimary;
      borderColor = AppTheme.goldPrimary;
      child = Text('$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12));
    } else {
      bgColor = AppTheme.surfaceElevated;
      borderColor = AppTheme.borderSubtle;
      child = Text('${index + 1}', style: TextStyle(color: AppTheme.textMuted, fontSize: 12));
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: child,
    );
  }
}

class StepConnectorPainter extends CustomPainter {
  final bool isCompleted;

  StepConnectorPainter({required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted ? AppTheme.accentGreen : AppTheme.borderSubtle
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset.zero,
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

