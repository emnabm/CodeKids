class DailyFlamesDto {
  const DailyFlamesDto({
    this.date,
    required this.flames,
  });

  final String? date;
  final int flames;

  factory DailyFlamesDto.fromJson(Map<String, dynamic> json) {
    return DailyFlamesDto(
      date: json['date'] as String?,
      flames: (json['flames'] as num?)?.toInt() ?? 0,
    );
  }
}

class LevelProgressDto {
  const LevelProgressDto({
    required this.levelId,
    required this.levelOrder,
    this.levelTitle,
    required this.totalStages,
    required this.completedStages,
    required this.completionPercentage,
    required this.isCompleted,
  });

  final String levelId;
  final int levelOrder;
  final String? levelTitle;
  final int totalStages;
  final int completedStages;
  final double completionPercentage;
  final bool isCompleted;

  factory LevelProgressDto.fromJson(Map<String, dynamic> json) {
    return LevelProgressDto(
      levelId: (json['levelId'] ?? '').toString(),
      levelOrder: (json['levelOrder'] as num?)?.toInt() ?? 0,
      levelTitle: json['levelTitle'] as String?,
      totalStages: (json['totalStages'] as num?)?.toInt() ?? 0,
      completedStages: (json['completedStages'] as num?)?.toInt() ?? 0,
      completionPercentage:
          (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

class StatsResponseDto {
  const StatsResponseDto({
    required this.childId,
    this.childName,
    required this.totalCompletedStages,
    required this.totalFlames,
    required this.currentStreakDays,
    required this.flamesPerDay,
    required this.levelProgress,
  });

  final String childId;
  final String? childName;
  final int totalCompletedStages;
  final int totalFlames;
  final int currentStreakDays;
  final List<DailyFlamesDto> flamesPerDay;
  final List<LevelProgressDto> levelProgress;

  factory StatsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawDaily = json['flamesPerDay'] as List?;
    final rawLevels = json['levelProgress'] as List?;
    return StatsResponseDto(
      childId: (json['childId'] ?? '').toString(),
      childName: json['childName'] as String?,
      totalCompletedStages:
          (json['totalCompletedStages'] as num?)?.toInt() ?? 0,
      totalFlames: (json['totalFlames'] as num?)?.toInt() ?? 0,
      currentStreakDays: (json['currentStreakDays'] as num?)?.toInt() ?? 0,
      flamesPerDay: rawDaily == null
          ? const []
          : rawDaily
              .whereType<Map>()
              .map(
                (d) => DailyFlamesDto.fromJson(Map<String, dynamic>.from(d)),
              )
              .toList(),
      levelProgress: rawLevels == null
          ? const []
          : rawLevels
              .whereType<Map>()
              .map(
                (l) => LevelProgressDto.fromJson(Map<String, dynamic>.from(l)),
              )
              .toList(),
    );
  }
}
