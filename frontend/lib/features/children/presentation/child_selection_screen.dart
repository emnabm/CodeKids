import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/shared/widgets/async_state_view.dart';
import 'package:frontend/shared/widgets/child_avatar.dart';
import 'package:frontend/shared/widgets/flame_counter.dart';
import 'package:frontend/shared/widgets/mascot.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:go_router/go_router.dart';

class ChildSelectionScreen extends ConsumerStatefulWidget {
  const ChildSelectionScreen({super.key});

  @override
  ConsumerState<ChildSelectionScreen> createState() =>
      _ChildSelectionScreenState();
}

class _ChildSelectionScreenState extends ConsumerState<ChildSelectionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(childrenControllerProvider);
      if (state.children.isEmpty && !state.isLoading) {
        ref.read(childrenControllerProvider.notifier).loadChildren();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final state = ref.watch(childrenControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l10n.logout,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SpaceBackground(
        showPlanets: true,
        child: SafeArea(
          child: AsyncStateView(
            isLoading: state.isLoading,
            error: state.error,
            onRetry: () =>
                ref.read(childrenControllerProvider.notifier).loadChildren(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  const Mascot(kind: MascotKind.astronaut, size: 84),
                  const SizedBox(height: 14),
                  Text(
                    l10n.selectChildTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 26,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.selectChildSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.mutedText, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: state.children.isEmpty
                        ? Center(
                            child: Text(
                              l10n.createChildSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colors.mutedText),
                            ),
                          )
                        : ListView.separated(
                            itemCount: state.children.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final child = state.children[index];
                              return Material(
                                color: colors.card,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () async {
                                    await ref
                                        .read(
                                          childrenControllerProvider.notifier,
                                        )
                                        .selectChild(child);
                                    if (!context.mounted) return;
                                    context.go(AppRoutes.map);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        ChildAvatar(
                                          avatarId: child.avatarId,
                                          size: 56,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                child.name ?? '',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${l10n.ageLabel}: ${child.age}',
                                                style: TextStyle(
                                                  color: colors.mutedText,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FlameCounter(
                                          flames: child.flames,
                                          compact: true,
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: colors.mutedText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: l10n.addChild,
                    leadingIcon: Icons.person_add_alt_1_rounded,
                    onPressed: () => context.push(AppRoutes.createChild),
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
