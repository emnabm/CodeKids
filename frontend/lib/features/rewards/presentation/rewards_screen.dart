import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/badges/badge_mapper.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/rewards/application/rewards_controller.dart';
import 'package:frontend/features/rewards/data/models/reward_models.dart';
import 'package:frontend/shared/widgets/async_state_view.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:intl/intl.dart';

/// Matches `docs/design/Rewards.png`.
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  void _openHistorySheet(
    BuildContext context,
    List<TransactionDto> transactions,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final dateFmt = DateFormat.yMMMd().add_Hm();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.transactionHistoryTitle,
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: transactions.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noTransactionsYet,
                              style: TextStyle(color: colors.mutedText),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: transactions.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) {
                              final tx = transactions[index];
                              final isPositive = tx.amount >= 0;
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.cardElevated,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      color: isPositive
                                          ? colors.flame
                                          : colors.error,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tx.reason ?? '-',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            dateFmt.format(
                                              tx.createdAt.toLocal(),
                                            ),
                                            style: TextStyle(
                                              color: colors.mutedText,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      isPositive
                                          ? '+${tx.amount}'
                                          : '${tx.amount}',
                                      style: TextStyle(
                                        color: isPositive
                                            ? colors.success
                                            : colors.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final state = ref.watch(rewardsControllerProvider);

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: AsyncStateView(
            isLoading: state.isLoading && state.data == null,
            error: state.data == null ? state.error : null,
            onRetry: () =>
                ref.read(rewardsControllerProvider.notifier).loadRewards(),
            child: state.data == null
                ? const SizedBox.shrink()
                : RefreshIndicator(
                    color: colors.primary,
                    onRefresh: () => ref
                        .read(rewardsControllerProvider.notifier)
                        .loadRewards(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                      children: [
                        Text(
                          l10n.myRewardsTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 20),
                        _MetricCard(
                          leading: Icon(
                            Icons.local_fire_department_rounded,
                            color: colors.flame,
                            size: 58,
                          ),
                          value: '${state.data!.flames}',
                          valueColor: const Color(0xFFB39DFF),
                          label: l10n.flamesLabel,
                        ),
                        const SizedBox(height: 14),
                        _MetricCard(
                          leading: Image.asset(
                            'assets/images/calendrier.png',
                            width: 56,
                            height: 56,
                          ),
                          value: '${state.data!.streakDays}',
                          valueColor: const Color(0xFF9F87FF),
                          label: l10n.consecutiveDaysLabel,
                        ),
                        if (state.data!.sevenDayActivity.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            l10n.sevenDayActivityTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _SevenDayRow(activity: state.data!.sevenDayActivity),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          l10n.earnedBadgesTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.card,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: colors.border),
                          ),
                          child: state.data!.badges.isEmpty
                              ? Text(
                                  l10n.noBadgesYet,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: colors.mutedText),
                                )
                              : Wrap(
                                  spacing: 14,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: state.data!.badges.map((badge) {
                                    final visual = BadgeMapper.resolve(
                                      iconUrl: badge.iconUrl,
                                      condition: badge.condition,
                                      name: badge.name,
                                    );
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
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
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 80,
                                            ),
                                            child: Text(
                                              badge.name!,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  }).toList(),
                                ),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: l10n.viewHistory,
                          onPressed: () => _openHistorySheet(
                            context,
                            state.data!.transactions,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.leading,
    required this.value,
    required this.valueColor,
    required this.label,
  });

  final Widget leading;
  final String value;
  final Color valueColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SevenDayRow extends StatelessWidget {
  const _SevenDayRow({required this.activity});

  final List<DayActivityDto> activity;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: activity.map((day) {
          final parsed =
              day.date != null ? DateTime.tryParse(day.date!) : null;
          final dayLabel = parsed != null
              ? DateFormat.E().format(parsed).substring(0, 1).toUpperCase()
              : '•';
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: day.isActive
                      ? colors.flame.withValues(alpha: 0.22)
                      : colors.cardElevated,
                  border: Border.all(
                    color: day.isActive ? colors.flame : colors.border,
                  ),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: day.isActive
                      ? colors.flame
                      : colors.mutedText.withValues(alpha: 0.35),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dayLabel,
                style: TextStyle(
                  color: day.isActive ? Colors.white : colors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
