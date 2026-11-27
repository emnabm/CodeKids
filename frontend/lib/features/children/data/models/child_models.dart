import 'package:frontend/core/utils/dto_bounds.dart';

class CreateChildRequestDto {
  const CreateChildRequestDto({
    required this.name,
    required this.age,
    required this.avatarId,
  });

  final String name;
  final int age;
  final String avatarId;

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': RequestBounds.clampChildAge(age),
        'avatarId': avatarId,
      };
}

class ChildDto {
  const ChildDto({
    required this.id,
    this.name,
    required this.age,
    this.avatarId,
    required this.flames,
    required this.streakDays,
    this.lastActiveDate,
  });

  final String id;
  final String? name;
  final int age;
  final String? avatarId;
  final int flames;
  final int streakDays;
  final DateTime? lastActiveDate;

  ChildDto copyWith({
    String? name,
    int? age,
    String? avatarId,
    int? flames,
    int? streakDays,
    DateTime? lastActiveDate,
  }) {
    return ChildDto(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarId: avatarId ?? this.avatarId,
      flames: flames ?? this.flames,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  factory ChildDto.fromJson(Map<String, dynamic> json) {
    final rawDate = json['lastActiveDate'] as String?;
    return ChildDto(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String?,
      age: (json['age'] as num?)?.toInt() ?? 10,
      avatarId: json['avatarId'] as String?,
      flames: (json['flames'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      lastActiveDate: rawDate != null ? DateTime.tryParse(rawDate) : null,
    );
  }
}
