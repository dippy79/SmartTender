import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PulseRing extends StatelessWidget {
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  const PulseRing({
    super.key,
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.accentPurple,
                  width: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
