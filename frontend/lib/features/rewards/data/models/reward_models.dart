class DayActivityDto {
  const DayActivityDto({
    this.date,
    required this.flamesEarned,
    required this.stagesCompleted,
    required this.isActive,
  });

  final String? date;
  final int flamesEarned;
  final int stagesCompleted;
  final bool isActive;

  factory DayActivityDto.fromJson(Map<String, dynamic> json) {
    return DayActivityDto(
      date: json['date'] as String?,
      flamesEarned: (json['flamesEarned'] as num?)?.toInt() ?? 0,
      stagesCompleted: (json['stagesCompleted'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }
}

class TransactionDto {
  const TransactionDto({
    required this.id,
    required this.amount,
    this.reason,
    required this.createdAt,
  });

  final String id;
  final int amount;
  final String? reason;
  final DateTime createdAt;

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] as String?;
    return TransactionDto(
      id: (json['id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String?,
      createdAt: rawDate != null
          ? (DateTime.tryParse(rawDate) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

class ChildBadgeDto {
  const ChildBadgeDto({
    required this.id,
    this.name,
    this.condition,
    this.iconUrl,
    required this.earnedAt,
  });

  final String id;
  final String? name;
  final String? condition;
  final String? iconUrl;
  final DateTime earnedAt;

  factory ChildBadgeDto.fromJson(Map<String, dynamic> json) {
    final rawDate = json['earnedAt'] as String?;
    return ChildBadgeDto(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String?,
      condition: json['condition'] as String?,
      iconUrl: json['iconUrl'] as String?,
      earnedAt: rawDate != null
          ? (DateTime.tryParse(rawDate) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}

class RewardResponseDto {
  const RewardResponseDto({
    required this.flames,
    required this.streakDays,
    required this.sevenDayActivity,
    required this.transactions,
    required this.badges,
  });

  final int flames;
  final int streakDays;
  final List<DayActivityDto> sevenDayActivity;
  final List<TransactionDto> transactions;
  final List<ChildBadgeDto> badges;

  factory RewardResponseDto.fromJson(Map<String, dynamic> json) {
    final rawActivity = json['sevenDayActivity'] as List?;
    final rawTransactions = json['transactions'] as List?;
    final rawBadges = json['badges'] as List?;

    return RewardResponseDto(
      flames: (json['flames'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      sevenDayActivity: rawActivity == null
          ? const []
          : rawActivity
              .whereType<Map>()
              .map(
                (a) => DayActivityDto.fromJson(Map<String, dynamic>.from(a)),
              )
              .toList(),
      transactions: rawTransactions == null
          ? const []
          : rawTransactions
              .whereType<Map>()
              .map(
                (t) => TransactionDto.fromJson(Map<String, dynamic>.from(t)),
              )
              .toList(),
      badges: rawBadges == null
          ? const []
          : rawBadges
              .whereType<Map>()
              .map(
                (b) => ChildBadgeDto.fromJson(Map<String, dynamic>.from(b)),
              )
              .toList(),
    );
  }
}
