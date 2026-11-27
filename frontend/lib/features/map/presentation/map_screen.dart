import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/map/application/map_controller.dart';
import 'package:frontend/features/map/data/models/map_models.dart';
import 'package:frontend/features/map/presentation/widgets/zigzag_path_painter.dart';
import 'package:frontend/shared/widgets/async_state_view.dart';
import 'package:frontend/shared/widgets/child_avatar.dart';
import 'package:frontend/shared/widgets/flame_counter.dart';
import 'package:frontend/shared/widgets/space_background.dart';
import 'package:frontend/shared/widgets/stage_node.dart';
import 'package:go_router/go_router.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key, this.onStageTap});

  /// Optional test hook; defaults to navigating to `/stage/:id`.
  final ValueChanged<MapStageDto>? onStageTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(
      childrenControllerProvider.select((s) => s.activeChild),
    );
    final mapState = ref.watch(mapControllerProvider);
    final colors = context.ckColors;

    final displayName = mapState.data?.childName ?? child?.name ?? '';
    final flames = mapState.data?.flames ?? child?.flames ?? 0;

    return Scaffold(
      body: SpaceBackground(
        child: SafeArea(
          child: Column(
            children: [
              _MapHeader(
                childName: displayName,
                avatarId: child?.avatarId,
                flames: flames,
                onOpenProfile: () => context.go(AppRoutes.profile),
              ),
              Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.flame.withValues(alpha: 0.9),
                      colors.primary.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Expanded(
                child: AsyncStateView(
                  isLoading: mapState.isLoading && mapState.data == null,
                  error: mapState.data == null ? mapState.error : null,
                  onRetry: () =>
                      ref.read(mapControllerProvider.notifier).loadMap(),
                  child: mapState.data == null
                      ? const SizedBox.shrink()
                      : RefreshIndicator(
                          color: colors.primary,
                          onRefresh: () => ref
                              .read(mapControllerProvider.notifier)
                              .loadMap(),
                          child: _MapLevelsBody(
                            levels: mapState.data!.levels,
                            onStageTap: (stage) {
                              if (onStageTap != null) {
                                onStageTap!(stage);
                              } else {
                                context.push(AppRoutes.stage(stage.id));
                              }
                            },
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.childName,
    required this.avatarId,
    required this.flames,
    required this.onOpenProfile,
  });

  final String childName;
  final String? avatarId;
  final int flames;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          ChildAvatar(
            avatarId: avatarId,
            size: 46,
            borderColor: const Color(0xFF9F87FF),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              childName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FlameCounter(flames: flames),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Profile',
            onPressed: onOpenProfile,
            icon: Image.asset(
              'assets/images/parametres.png',
              width: 28,
              height: 28,
              errorBuilder: (_, _, _) => const Icon(
                Icons.settings_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapLevelsBody extends StatelessWidget {
  const _MapLevelsBody({
    required this.levels,
    required this.onStageTap,
  });

  final List<MapLevelDto> levels;
  final ValueChanged<MapStageDto> onStageTap;

  @override
  Widget build(BuildContext context) {
    if (levels.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 160)],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      itemCount: levels.length,
      itemBuilder: (context, index) {
        final level = levels[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _LevelZigzagSection(
            level: level,
            onStageTap: onStageTap,
          ),
        );
      },
    );
  }
}

class _LevelZigzagSection extends StatelessWidget {
  const _LevelZigzagSection({
    required this.level,
    required this.onStageTap,
  });

  final MapLevelDto level;
  final ValueChanged<MapStageDto> onStageTap;

  static const double _rowHeight = 132.0;
  static const double _nodeSize = 76.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    // Stages go bottom-to-top like Map.PNG (Stage 1 at bottom with astronaut).
    final orderedBottomToTop = [...level.stages]
      ..sort((a, b) => a.order.compareTo(b.order));
    final displayStages = orderedBottomToTop.reversed.toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.card.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: level.isLocked
                  ? colors.border
                  : colors.primary.withValues(alpha: 0.65),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (level.isLocked) ...[
                Image.asset('assets/images/cadenas.png', width: 18),
                const SizedBox(width: 8),
              ] else ...[
                Image.asset('assets/images/etoile.png', width: 18),
                const SizedBox(width: 8),
              ],
              Text(
                '${level.order}. ${level.title ?? ''}',
                style: TextStyle(
                  color: level.isLocked ? colors.mutedText : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final totalHeight =
                (displayStages.length * _rowHeight).clamp(240.0, 2000.0);

            // Alternating x-fractions matching the S-curve in Map.PNG.
            const xFractionsBottomToTop = [0.46, 0.54, 0.30, 0.64, 0.34, 0.66];
            final nodeCenters = <Offset>[];
            final activeStates = <bool>[];

            for (var visualIndex = 0;
                visualIndex < displayStages.length;
                visualIndex++) {
              final stageIndexFromBottom =
                  displayStages.length - 1 - visualIndex;
              final xFrac = xFractionsBottomToTop[
                  stageIndexFromBottom % xFractionsBottomToTop.length];
              final cx = width * xFrac;
              final cy = (visualIndex * _rowHeight) + (_rowHeight / 2) - 8;
              nodeCenters.add(Offset(cx, cy));
              final stage = displayStages[visualIndex];
              activeStates.add(
                !level.isLocked && stage.status != StageStatus.locked,
              );
            }

            return SizedBox(
              width: width,
              height: totalHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative space props around the path matching Map.PNG
                  Positioned(
                    right: 12,
                    top: 18,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.85,
                        child: Image.asset(
                          'assets/images/planete_violette.png',
                          width: 56,
                        ),
                      ),
                    ),
                  ),
                  if (displayStages.length >= 3)
                    Positioned(
                      left: 10,
                      top: totalHeight * 0.44,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: 0.85,
                          child: Image.asset(
                            'assets/images/lune.png',
                            width: 48,
                          ),
                        ),
                      ),
                    ),
                  // Bottom pedestal decorations beside Stage 1
                  Positioned(
                    left: 8,
                    bottom: 18,
                    child: IgnorePointer(
                      child: Image.asset(
                        'assets/images/saturne.png',
                        width: 74,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 8,
                    child: IgnorePointer(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/astronaute.png',
                            width: 82,
                          ),
                          Container(
                            width: 68,
                            height: 14,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: colors.cardElevated,
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: Size(width, totalHeight),
                    painter: ZigzagPathPainter(
                      nodeCenters: nodeCenters,
                      activeStates: activeStates,
                    ),
                  ),
                  for (var i = 0; i < displayStages.length; i++)
                    Positioned(
                      left: nodeCenters[i].dx - 70,
                      top: nodeCenters[i].dy - (_nodeSize / 2) - 6,
                      width: 140,
                      child: Center(
                        child: StageNode(
                          order: displayStages[i].order,
                          status: level.isLocked
                              ? StageStatus.locked
                              : displayStages[i].status,
                          title: displayStages[i].title ?? '',
                          size: _nodeSize,
                          onTap: (!level.isLocked &&
                                  displayStages[i].status != StageStatus.locked)
                              ? () => onStageTap(displayStages[i])
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
