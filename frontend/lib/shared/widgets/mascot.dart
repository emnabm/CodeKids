import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

enum MascotKind {
  astronaut,
  robot,
  rocket,
}

/// Renders the transparent space character illustration from `assets/images/`.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.kind = MascotKind.astronaut,
    this.size = 110,
    this.withGlowHalo = true,
  });

  final MascotKind kind;
  final double size;
  final bool withGlowHalo;

  String get _assetPath => switch (kind) {
        MascotKind.astronaut => 'assets/images/astronaute.png',
        MascotKind.robot => 'assets/images/robot.png',
        MascotKind.rocket => 'assets/images/fusee.png',
      };

  IconData get _fallbackIcon => switch (kind) {
        MascotKind.astronaut => Icons.rocket_rounded,
        MascotKind.robot => Icons.smart_toy_rounded,
        MascotKind.rocket => Icons.rocket_launch_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (withGlowHalo)
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.primary.withValues(alpha: 0.45),
                    colors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          Image.asset(
            _assetPath,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              _fallbackIcon,
              size: size * 0.6,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
