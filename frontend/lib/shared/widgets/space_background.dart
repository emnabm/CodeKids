import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Cosmic space backdrop matching `ecranAccueil.png` and `creerCompte.PNG`.
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({
    super.key,
    required this.child,
    this.showPlanets = false,
    this.showBottomClouds = false,
  });

  final Widget child;
  final bool showPlanets;
  final bool showBottomClouds;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF090524),
            const Color(0xFF170D44),
            colors.background,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const IgnorePointer(
            child: CustomPaint(painter: _StarfieldPainter()),
          ),
          Positioned(
            top: -70,
            right: -60,
            child: _GlowOrb(
              size: 240,
              color: colors.primary.withValues(alpha: 0.24),
            ),
          ),
          Positioned(
            top: 140,
            left: -80,
            child: _GlowOrb(
              size: 220,
              color: const Color(0xFF6D28D9).withValues(alpha: 0.18),
            ),
          ),
          if (showBottomClouds) ...[
            Positioned(
              bottom: -55,
              left: -55,
              child: _GlowOrb(
                size: 200,
                color: const Color(0xFF7C3AED).withValues(alpha: 0.42),
              ),
            ),
            Positioned(
              bottom: -45,
              right: -50,
              child: _GlowOrb(
                size: 190,
                color: const Color(0xFF6D28D9).withValues(alpha: 0.42),
              ),
            ),
          ],
          if (showPlanets) ...[
            Positioned(
              top: 110,
              left: -18,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/images/saturne.png',
                    width: 88,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 165,
              right: -24,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.85,
                  child: Image.asset(
                    'assets/images/planete_violette.png',
                    width: 82,
                  ),
                ),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  const _StarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final whitePaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final goldPaint = Paint()..color = const Color(0xFFFFD23F).withValues(alpha: 0.75);

    for (var i = 0; i < 42; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final radius = 0.8 + rng.nextDouble() * 1.4;
      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        i % 7 == 0 ? goldPaint : whitePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
