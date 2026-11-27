import 'package:flutter/material.dart';
import 'package:frontend/core/badges/badge_mapper.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/space_background.dart';

/// Matches `docs/design/FinDeNiveau.png`.
///
/// Displays only server-returned values (`flamesEarned`, `streakBonus`,
/// `streakDays`, `unlockedStageId`, `unlockedLevelId`, `newBadges`).
class StageCompleteView extends StatelessWidget {
  const StageCompleteView({
    super.key,
    required this.stage,
    required this.result,
    required this.onContinue,
  });

  final StageDetailDto stage;
  final CompleteStageResponseDto result;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final isReplay = result.flamesEarned == 0 && result.streakBonus == 0;
    final isLevelComplete = result.unlockedLevelId != null ||
        stage.type == StageType.finalTest;

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                // Hero star + check badge (with subtle celebration when not replay)
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (!isReplay)
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              colors.flame.withValues(alpha: 0.35),
                              colors.flame.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    Image.asset(
                      'assets/images/etoile.png',
                      width: 112,
                      height: 112,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Image.asset(
                        'assets/images/validation.png',
                        width: 38,
                        height: 38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  isLevelComplete
                      ? l10n.levelCompleteTitle
                      : l10n.stageCompleteTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isReplay ? Colors.white : const Color(0xFFFFD23F),
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isReplay) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.replayNoFlamesNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.mutedText, fontSize: 15),
                  ),
                ],
                const SizedBox(height: 22),
                // Reward card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.rewardLabel,
                        style: TextStyle(
                          color: colors.mutedText,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department_rounded,
                            color: isReplay ? colors.mutedText : colors.flame,
                            size: 36,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${result.flamesEarned}',
                            style: TextStyle(
                              color: isReplay
                                  ? colors.mutedText
                                  : const Color(0xFFFFD23F),
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (result.streakBonus > 0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.flame.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            l10n.streakBonusLabel(result.streakBonus),
                            style: TextStyle(
                              color: colors.flame,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Streak card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/calendrier.png',
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.currentStreakLabel,
                              style: TextStyle(
                                color: colors.mutedText,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  l10n.streakDaysCount(result.streakDays),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.local_fire_department_rounded,
                                  color: colors.flame,
                                  size: 22,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (result.newBadges.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: colors.success.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.newBadgesEarned,
                          style: TextStyle(
                            color: colors.success,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 14,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: result.newBadges.map((badge) {
                            final visual = BadgeMapper.resolve(
                              iconUrl: badge.iconUrl,
                              condition: badge.condition,
                              name: badge.name,
                            );
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: visual.backgroundColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: visual.accentColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.asset(
                                    visual.assetPath,
                                    errorBuilder: (_, _, _) => Icon(
                                      visual.fallbackIcon,
                                      color: visual.accentColor,
                                    ),
                                  ),
                                ),
                                if (badge.name != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    badge.name!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                // Golden Continue button matching FinDeNiveau.png
                PrimaryButton(
                  label: l10n.continueButton,
                  backgroundColor: const Color(0xFFFFD23F),
                  foregroundColor: const Color(0xFF0D0830),
                  onPressed: onContinue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
