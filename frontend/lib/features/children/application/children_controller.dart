import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/core/l10n/locale_provider.dart';
import 'package:frontend/features/children/data/models/child_models.dart';

class ChildrenState {
  const ChildrenState({
    this.children = const [],
    this.activeChildId,
    this.isLoading = false,
    this.error,
  });

  final List<ChildDto> children;
  final String? activeChildId;
  final bool isLoading;
  final Object? error;

  ChildDto? get activeChild {
    if (activeChildId == null) return null;
    for (final child in children) {
      if (child.id == activeChildId) return child;
    }
    return null;
  }

  ChildrenState copyWith({
    List<ChildDto>? children,
    String? activeChildId,
    bool clearActiveChild = false,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return ChildrenState(
      children: children ?? this.children,
      activeChildId:
          clearActiveChild ? null : (activeChildId ?? this.activeChildId),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ChildrenController extends Notifier<ChildrenState> {
  @override
  ChildrenState build() => const ChildrenState();

  void setLoadedChildren(List<ChildDto> children) {
    state = state.copyWith(
      children: children,
      isLoading: false,
      clearError: true,
    );
  }

  Future<void> loadChildren() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await ref.read(childrenRepositoryProvider).getChildren();
      final savedId = ref.read(tokenStorageProvider).activeChildId;
      final stillExists =
          savedId != null && list.any((child) => child.id == savedId);
      state = state.copyWith(
        children: list,
        activeChildId: stillExists ? savedId : null,
        clearActiveChild: !stillExists,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<ChildDto> createChild({
    required String name,
    required int age,
    required String avatarId,
    required String interfaceLanguage,
  }) async {
    final created = await ref.read(childrenRepositoryProvider).createChild(
          CreateChildRequestDto(
            name: name.trim(),
            age: age,
            avatarId: avatarId,
          ),
        );
    final updated = [...state.children, created];
    await ref.read(tokenStorageProvider).saveActiveChildId(created.id);
    await ref
        .read(localeProvider.notifier)
        .setChildLocale(created.id, interfaceLanguage);
    state = state.copyWith(
      children: updated,
      activeChildId: created.id,
      clearError: true,
    );
    return created;
  }

  Future<void> selectChild(ChildDto child) async {
    await ref.read(tokenStorageProvider).saveActiveChildId(child.id);
    await ref.read(localeProvider.notifier).applyChildLocaleIfSaved(child.id);
    state = state.copyWith(activeChildId: child.id);
  }

  Future<void> clearActiveChild() async {
    await ref.read(tokenStorageProvider).saveActiveChildId(null);
    state = state.copyWith(clearActiveChild: true);
  }

  Future<void> deleteChild(String childId) async {
    await ref.read(childrenRepositoryProvider).deleteChild(childId);
    final remaining = state.children.where((c) => c.id != childId).toList();
    final wasActive = state.activeChildId == childId;
    if (wasActive) {
      await ref.read(tokenStorageProvider).saveActiveChildId(null);
    }
    state = state.copyWith(
      children: remaining,
      clearActiveChild: wasActive,
    );
  }

  /// Updates the active child's server-reported flame / streak values.
  void updateActiveChildMetrics({int? flames, int? streakDays}) {
    final activeId = state.activeChildId;
    if (activeId == null) return;
    final updated = state.children.map((child) {
      if (child.id != activeId) return child;
      return child.copyWith(
        flames: flames ?? child.flames,
        streakDays: streakDays ?? child.streakDays,
      );
    }).toList();
    state = state.copyWith(children: updated);
  }

  void reset() {
    state = const ChildrenState();
  }
}

final childrenControllerProvider =
    NotifierProvider<ChildrenController, ChildrenState>(
  ChildrenController.new,
);
