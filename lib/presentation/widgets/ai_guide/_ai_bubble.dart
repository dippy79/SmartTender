import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '_pulse_ring.dart';

class AiBubble extends StatelessWidget {
  final VoidCallback onTap;
  final bool isExpanded;

  const AiBubble({
    super.key,
    required this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isExpanded ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!isExpanded) PulseRing(
              scaleAnimation: AlwaysStoppedAnimation(1.2),
              opacityAnimation: AlwaysStoppedAnimation(0.5),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
