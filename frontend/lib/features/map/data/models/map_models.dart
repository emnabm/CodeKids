enum StageStatus {
  locked,
  available,
  completed;

  static StageStatus fromApi(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'available':
      case 'unlocked':
        return StageStatus.available;
      case 'completed':
      case 'done':
        return StageStatus.completed;
      case 'locked':
      default:
        return StageStatus.locked;
    }
  }
}

class MapStageDto {
  const MapStageDto({
    required this.id,
    required this.order,
    this.type,
    this.title,
    required this.rewardFlames,
    required this.status,
    required this.flamesEarned,
    required this.attempts,
  });

  final String id;
  final int order;
  final String? type;
  final String? title;
  final int rewardFlames;
  final StageStatus status;
  final int flamesEarned;
  final int attempts;

  factory MapStageDto.fromJson(Map<String, dynamic> json) {
    return MapStageDto(
      id: (json['id'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      type: json['type'] as String?,
      title: json['title'] as String?,
      rewardFlames: (json['rewardFlames'] as num?)?.toInt() ?? 0,
      status: StageStatus.fromApi(json['status'] as String?),
      flamesEarned: (json['flamesEarned'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    );
  }
}

class MapLevelDto {
  const MapLevelDto({
    required this.id,
    required this.order,
    this.title,
    this.theme,
    this.iconUrl,
    required this.isLocked,
    required this.stages,
  });

  final String id;
  final int order;
  final String? title;
  final String? theme;
  final String? iconUrl;
  final bool isLocked;
  final List<MapStageDto> stages;

  factory MapLevelDto.fromJson(Map<String, dynamic> json) {
    final rawStages = json['stages'] as List?;
    return MapLevelDto(
      id: (json['id'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      title: json['title'] as String?,
      theme: json['theme'] as String?,
      iconUrl: json['iconUrl'] as String?,
      isLocked: json['isLocked'] as bool? ?? false,
      stages: rawStages == null
          ? const []
          : rawStages
              .whereType<Map>()
              .map((s) => MapStageDto.fromJson(Map<String, dynamic>.from(s)))
              .toList(),
    );
  }
}

class MapResponseDto {
  const MapResponseDto({
    required this.childId,
    this.childName,
    required this.flames,
    required this.streakDays,
    required this.levels,
  });

  final String childId;
  final String? childName;
  final int flames;
  final int streakDays;
  final List<MapLevelDto> levels;

  factory MapResponseDto.fromJson(Map<String, dynamic> json) {
    final rawLevels = json['levels'] as List?;
    return MapResponseDto(
      childId: (json['childId'] ?? '').toString(),
      childName: json['childName'] as String?,
      flames: (json['flames'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      levels: rawLevels == null
          ? const []
          : rawLevels
              .whereType<Map>()
              .map((l) => MapLevelDto.fromJson(Map<String, dynamic>.from(l)))
              .toList(),
    );
  }
}
