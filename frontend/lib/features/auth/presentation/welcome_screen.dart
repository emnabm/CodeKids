import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/l10n/locale_provider.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLang = ref.watch(localeProvider).languageCode;

    return Scaffold(
      body: SpaceBackground(
        showBottomClouds: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 24,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: _LanguageTogglePill(
                            currentLanguage: currentLang,
                            onSelect: (code) => ref
                                .read(localeProvider.notifier)
                                .setGlobalLocale(code),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const _BrandLogo(),
                        const SizedBox(height: 6),
                        Text(
                          l10n.tagline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _WelcomeSpaceHero(),
                        const SizedBox(height: 12),
                        _HighlightedHeadline(
                          headline: l10n.welcomeHeadline,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.welcomeSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.ckColors.mutedText,
                            fontSize: 15,
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: l10n.getStarted,
                          leadingIcon: Icons.rocket_launch_rounded,
                          trailingIcon: Icons.arrow_forward_rounded,
                          onPressed: () => context.push(AppRoutes.register),
                        ),
                        const SizedBox(height: 12),
                        _LoginOutlineButton(
                          label: l10n.login,
                          onPressed: () => context.push(AppRoutes.login),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: -16,
          child: SizedBox(
            width: 170,
            height: 28,
            child: CustomPaint(painter: _ShootingStarArcPainter()),
          ),
        ),
        Positioned(
          top: -22,
          right: 26,
          child: Image.asset('assets/images/etoile.png', width: 22),
        ),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
            children: const [
              TextSpan(
                text: 'Code',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'Kids',
                style: TextStyle(color: Color(0xFF915BFF)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShootingStarArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x00FFD23F), Color(0xFFFFD23F)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(10, size.height - 4)
      ..quadraticBezierTo(size.width * 0.55, -2, size.width - 12, 8);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WelcomeSpaceHero extends StatelessWidget {
  const _WelcomeSpaceHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ambient cosmic glow behind rocket & astronaut
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6B4CF5).withValues(alpha: 0.45),
                  const Color(0xFF2882E0).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            left: -14,
            top: 4,
            child: Image.asset('assets/images/saturne.png', width: 92),
          ),
          Positioned(
            right: -12,
            top: 12,
            child: Image.asset('assets/images/terre.png', width: 78),
          ),
          Positioned(
            left: 14,
            top: 102,
            child: Transform.rotate(
              angle: -0.18,
              child: const _FloatingBadge(
                child: Icon(
                  Icons.sports_esports_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 34,
            child: Transform.rotate(
              angle: 0.16,
              child: const _FloatingBadge(
                child: Text(
                  '</>',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 52,
            top: 24,
            child: Image.asset('assets/images/etoile.png', width: 32),
          ),
          Positioned(
            right: 68,
            bottom: 12,
            child: Image.asset('assets/images/etoile.png', width: 20),
          ),
          // Rocket + Astronaut centerpiece matching ecranAccueil.png
          Positioned(
            bottom: 12,
            child: Transform.rotate(
              angle: math.pi / 12,
              child: Image.asset(
                'assets/images/fusee.png',
                width: 156,
              ),
            ),
          ),
          Positioned(
            top: 22,
            child: Image.asset(
              'assets/images/astronaute.png',
              width: 148,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF281D7A).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF7B5CFF).withValues(alpha: 0.75),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4BD6).withValues(alpha: 0.4),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HighlightedHeadline extends StatelessWidget {
  const _HighlightedHeadline({required this.headline});

  final String headline;

  @override
  Widget build(BuildContext context) {
    final words = headline.split(' ');
    const highlightColor = Color(0xFFFFD23F);

    final spans = <TextSpan>[];
    for (var i = 0; i < words.length; i++) {
      final w = words[i];
      final clean = w.toLowerCase().replaceAll(RegExp(r'[^a-zàâéèêîôùûç]'), '');
      final isHighlight = clean == 'programming' || clean == 'programmer';
      spans.add(
        TextSpan(
          text: i == words.length - 1 ? w : '$w ',
          style: TextStyle(
            color: isHighlight ? highlightColor : Colors.white,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _SparkRays(flip: false),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                    height: 1.18,
                  ),
              children: spans,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const _SparkRays(flip: true),
      ],
    );
  }
}

class _SparkRays extends StatelessWidget {
  const _SparkRays({required this.flip});

  final bool flip;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: 0.45,
            child: Container(
              width: 14,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD23F),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Transform.rotate(
            angle: -0.35,
            child: Container(
              width: 14,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD23F),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginOutlineButton extends StatelessWidget {
  const _LoginOutlineButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF100B38).withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF7B5CFF).withValues(alpha: 0.8),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageTogglePill extends StatelessWidget {
  const _LanguageTogglePill({
    required this.currentLanguage,
    required this.onSelect,
  });

  final String currentLanguage;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.card.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final code in const ['fr', 'en'])
            GestureDetector(
              onTap: () => onSelect(code),
              child: Container(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: currentLanguage == code
                      ? colors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  code.toUpperCase(),
                  style: TextStyle(
                    color: currentLanguage == code
                        ? Colors.white
                        : colors.mutedText,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
