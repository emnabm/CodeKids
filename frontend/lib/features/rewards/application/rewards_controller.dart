import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/rewards/data/models/reward_models.dart';

class RewardsState {
  const RewardsState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  final RewardResponseDto? data;
  final bool isLoading;
  final Object? error;

  RewardsState copyWith({
    RewardResponseDto? data,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return RewardsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RewardsController extends Notifier<RewardsState> {
  String? _loadedChildId;

  @override
  RewardsState build() {
    final activeChildId = ref.watch(
      childrenControllerProvider.select((s) => s.activeChildId),
    );
    if (activeChildId != null && activeChildId != _loadedChildId) {
      _loadedChildId = activeChildId;
      Future.microtask(() => loadRewards(childId: activeChildId));
    } else if (activeChildId == null) {
      _loadedChildId = null;
    }
    return const RewardsState(isLoading: true);
  }

  Future<void> loadRewards({String? childId}) async {
    final targetId =
        childId ?? ref.read(childrenControllerProvider).activeChildId;
    if (targetId == null) return;

    state = state.copyWith(isLoading: state.data == null, clearError: true);
    try {
      final response =
          await ref.read(rewardsRepositoryProvider).getRewards(targetId);
      _loadedChildId = targetId;
      ref.read(childrenControllerProvider.notifier).updateActiveChildMetrics(
            flames: response.flames,
            streakDays: response.streakDays,
          );
      state = RewardsState(data: response, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}

final rewardsControllerProvider =
    NotifierProvider<RewardsController, RewardsState>(RewardsController.new);
