import 'package:flutter/material.dart';

/// Known seeded badge codes from docs/README.md.
enum KnownBadgeCode {
  firstStage,
  firstQuiz,
  level1Complete,
  streak3,
  streak7,
  unknown,
}

class BadgeVisual {
  const BadgeVisual({
    required this.code,
    required this.assetPath,
    required this.fallbackIcon,
    required this.backgroundColor,
    required this.accentColor,
  });

  final KnownBadgeCode code;
  final String assetPath;
  final IconData fallbackIcon;
  final Color backgroundColor;
  final Color accentColor;
}

/// Isolated badge icon/style mapper.
///
/// Update this single file once backend seeder `iconUrl` / `condition` values
/// (or an explicit `code` field) are finalized.
class BadgeMapper {
  const BadgeMapper._();

  static const BadgeVisual fallback = BadgeVisual(
    code: KnownBadgeCode.unknown,
    assetPath: 'assets/badges/badge_default.png',
    fallbackIcon: Icons.shield_rounded,
    backgroundColor: Color(0xFF1D3E8A),
    accentColor: Color(0xFF7BE0A0),
  );

  static BadgeVisual resolve({
    String? code,
    String? iconUrl,
    String? condition,
    String? name,
  }) {
    final haystack = [
      code ?? '',
      iconUrl ?? '',
      condition ?? '',
      name ?? '',
    ].join(' ').toUpperCase();

    if (haystack.contains('FIRST_STAGE') || haystack.contains('FIRST STEP')) {
      return const BadgeVisual(
        code: KnownBadgeCode.firstStage,
        assetPath: 'assets/badges/badge_first_stage.png',
        fallbackIcon: Icons.rocket_launch_rounded,
        backgroundColor: Color(0xFF42218E),
        accentColor: Color(0xFF60B5FF),
      );
    }
    if (haystack.contains('FIRST_QUIZ') || haystack.contains('QUIZ WHIZ')) {
      return const BadgeVisual(
        code: KnownBadgeCode.firstQuiz,
        assetPath: 'assets/badges/badge_first_quiz.png',
        fallbackIcon: Icons.star_rounded,
        backgroundColor: Color(0xFF0E6B50),
        accentColor: Color(0xFFFFC93C),
      );
    }
    if (haystack.contains('LEVEL_1_COMPLETE') ||
        haystack.contains('LEVEL 1 CHAMPION')) {
      return const BadgeVisual(
        code: KnownBadgeCode.level1Complete,
        assetPath: 'assets/badges/badge_level_1_complete.png',
        fallbackIcon: Icons.workspace_premium_rounded,
        backgroundColor: Color(0xFF7E1D34),
        accentColor: Color(0xFFFFD147),
      );
    }
    if (haystack.contains('STREAK_3') || haystack.contains('FLAME KEEPER')) {
      return const BadgeVisual(
        code: KnownBadgeCode.streak3,
        assetPath: 'assets/badges/badge_streak_3.png',
        fallbackIcon: Icons.local_fire_department_rounded,
        backgroundColor: Color(0xFF5A2A78),
        accentColor: Color(0xFFFFB020),
      );
    }
    if (haystack.contains('STREAK_7') || haystack.contains('FIRE MASTER')) {
      return const BadgeVisual(
        code: KnownBadgeCode.streak7,
        assetPath: 'assets/badges/badge_streak_7.png',
        fallbackIcon: Icons.emoji_events_rounded,
        backgroundColor: Color(0xFF4A1E4D),
        accentColor: Color(0xFFFFB020),
      );
    }

    return fallback;
  }
}
