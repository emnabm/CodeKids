import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/features/children/application/children_controller.dart';
import 'package:frontend/features/map/data/models/map_models.dart';

class MapState {
  const MapState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  final MapResponseDto? data;
  final bool isLoading;
  final Object? error;

  MapState copyWith({
    MapResponseDto? data,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return MapState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class MapController extends Notifier<MapState> {
  String? _loadedChildId;

  @override
  MapState build() {
    final activeChildId = ref.watch(
      childrenControllerProvider.select((s) => s.activeChildId),
    );
    if (activeChildId != null && activeChildId != _loadedChildId) {
      _loadedChildId = activeChildId;
      Future.microtask(() => loadMap(childId: activeChildId));
    } else if (activeChildId == null) {
      _loadedChildId = null;
    }
    return const MapState(isLoading: true);
  }

  Future<void> loadMap({String? childId}) async {
    final targetId =
        childId ?? ref.read(childrenControllerProvider).activeChildId;
    if (targetId == null) return;

    state = state.copyWith(isLoading: state.data == null, clearError: true);
    try {
      final response = await ref.read(mapRepositoryProvider).getMap(targetId);
      _loadedChildId = targetId;
      ref.read(childrenControllerProvider.notifier).updateActiveChildMetrics(
            flames: response.flames,
            streakDays: response.streakDays,
          );
      state = MapState(data: response, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }
}

final mapControllerProvider =
    NotifierProvider<MapController, MapState>(MapController.new);
