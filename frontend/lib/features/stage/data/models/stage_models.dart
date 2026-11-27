import 'dart:convert';

import 'package:frontend/core/utils/dto_bounds.dart';

enum StageType {
  explanation,
  quiz,
  finalTest;

  static StageType fromApi(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'explanation':
        return StageType.explanation;
      case 'final':
      case 'finaltest':
      case 'final_test':
        return StageType.finalTest;
      case 'quiz':
      default:
        return StageType.quiz;
    }
  }
}

enum QuestionType {
  mcq,
  trueFalse,
  order,
  fillBlank;

  static QuestionType fromApi(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'truefalse':
      case 'true_false':
        return QuestionType.trueFalse;
      case 'order':
        return QuestionType.order;
      case 'fillblank':
      case 'fill_blank':
        return QuestionType.fillBlank;
      case 'mcq':
      default:
        return QuestionType.mcq;
    }
  }
}

sealed class QuestionAnswer {
  const QuestionAnswer();

  factory QuestionAnswer.fromJson({
    required QuestionType type,
    required dynamic rawAnswer,
  }) {
    final map = _decodeJsonMap(rawAnswer);
    if (type == QuestionType.order) {
      final rawOrder = map['order'];
      final order = rawOrder is List
          ? rawOrder.map((e) => e.toString()).toList()
          : const <String>[];
      return OrderedValuesAnswer(order);
    }

    final correct = (map['correct'] ?? '').toString();
    return CorrectValueAnswer(correct);
  }
}

class CorrectValueAnswer extends QuestionAnswer {
  const CorrectValueAnswer(this.correct);

  final String correct;
}

class OrderedValuesAnswer extends QuestionAnswer {
  const OrderedValuesAnswer(this.order);

  final List<String> order;
}

class StageContent {
  const StageContent({
    this.heading,
    this.text,
    this.codeExample,
    this.raw,
  });

  final String? heading;
  final String? text;
  final String? codeExample;
  final dynamic raw;

  factory StageContent.fromDynamic(dynamic rawContent) {
    if (rawContent == null) {
      return const StageContent();
    }
    if (rawContent is String) {
      final trimmed = rawContent.trim();
      if (trimmed.startsWith('{')) {
        try {
          final decoded = jsonDecode(trimmed);
          if (decoded is Map) {
            return StageContent._fromMap(
              Map<String, dynamic>.from(decoded),
              rawContent,
            );
          }
        } catch (_) {
          // Fall through and treat as plain text.
        }
      }
      return StageContent(text: rawContent, raw: rawContent);
    }
    if (rawContent is Map) {
      return StageContent._fromMap(
        Map<String, dynamic>.from(rawContent),
        rawContent,
      );
    }
    return StageContent(text: rawContent.toString(), raw: rawContent);
  }

  factory StageContent._fromMap(Map<String, dynamic> map, dynamic raw) {
    final heading = (map['title'] ?? map['heading'] ?? map['subtitle']) as String?;
    final text = (map['explanation'] ??
            map['text'] ??
            map['body'] ??
            map['description'] ??
            map['summary']) as String?;
    final code = (map['code'] ??
            map['codeExample'] ??
            map['example'] ??
            map['snippet']) as String?;
    return StageContent(
      heading: heading,
      text: text,
      codeExample: code,
      raw: raw,
    );
  }
}

class StageQuestionDto {
  const StageQuestionDto({
    required this.id,
    required this.type,
    required this.text,
    required this.options,
    required this.answer,
    this.hintText,
    this.explanationText,
  });

  final String id;
  final QuestionType type;
  final String text;
  final List<String> options;
  final QuestionAnswer answer;
  final String? hintText;
  final String? explanationText;

  factory StageQuestionDto.fromJson(Map<String, dynamic> json) {
    final type = QuestionType.fromApi(json['type'] as String?);
    final rawOptions = _decodeJsonList(json['options']);
    return StageQuestionDto(
      id: (json['id'] ?? '').toString(),
      type: type,
      text: (json['text'] ?? '').toString(),
      options: rawOptions.map((e) => e.toString()).toList(),
      answer: QuestionAnswer.fromJson(
        type: type,
        rawAnswer: json['answer'],
      ),
      hintText: json['hintText'] as String?,
      explanationText: json['explanationText'] as String?,
    );
  }
}

class StageDetailDto {
  const StageDetailDto({
    required this.id,
    required this.levelId,
    required this.order,
    required this.type,
    this.title,
    required this.rewardFlames,
    this.content,
    required this.questions,
  });

  final String id;
  final String levelId;
  final int order;
  final StageType type;
  final String? title;
  final int rewardFlames;
  final StageContent? content;
  final List<StageQuestionDto> questions;

  factory StageDetailDto.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List?;
    return StageDetailDto(
      id: (json['id'] ?? '').toString(),
      levelId: (json['levelId'] ?? '').toString(),
      order: (json['order'] as num?)?.toInt() ?? 0,
      type: StageType.fromApi(json['type'] as String?),
      title: json['title'] as String?,
      rewardFlames: (json['rewardFlames'] as num?)?.toInt() ?? 0,
      content: json['content'] != null
          ? StageContent.fromDynamic(json['content'])
          : null,
      questions: rawQuestions == null
          ? const []
          : rawQuestions
              .whereType<Map>()
              .map(
                (q) => StageQuestionDto.fromJson(Map<String, dynamic>.from(q)),
              )
              .toList(),
    );
  }
}

class HintRequestDto {
  const HintRequestDto({
    required this.childId,
    required this.questionId,
  });

  final String childId;
  final String questionId;

  Map<String, dynamic> toJson() => {
        'childId': childId,
        'questionId': questionId,
      };
}

class HintResponseDto {
  const HintResponseDto({
    this.hintText,
    required this.cost,
    required this.flamesLeft,
  });

  final String? hintText;
  final int cost;
  final int flamesLeft;

  factory HintResponseDto.fromJson(Map<String, dynamic> json) {
    return HintResponseDto(
      hintText: json['hintText'] as String?,
      cost: (json['cost'] as num?)?.toInt() ?? 0,
      flamesLeft: (json['flamesLeft'] as num?)?.toInt() ?? 0,
    );
  }
}

class CompleteStageRequestDto {
  const CompleteStageRequestDto({
    required this.childId,
    required this.hintsUsed,
    required this.attempts,
  });

  final String childId;
  final int hintsUsed;
  final int attempts;

  Map<String, dynamic> toJson() => {
        'childId': childId,
        'hintsUsed': RequestBounds.clampHintsUsed(hintsUsed),
        'attempts': RequestBounds.clampAttempts(attempts),
      };
}

class BadgeAwardDto {
  const BadgeAwardDto({
    required this.id,
    this.name,
    this.condition,
    this.iconUrl,
  });

  final String id;
  final String? name;
  final String? condition;
  final String? iconUrl;

  factory BadgeAwardDto.fromJson(Map<String, dynamic> json) {
    return BadgeAwardDto(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String?,
      condition: json['condition'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }
}

class CompleteStageResponseDto {
  const CompleteStageResponseDto({
    required this.flamesEarned,
    required this.streakBonus,
    required this.flamesTotal,
    required this.streakDays,
    this.unlockedStageId,
    this.unlockedLevelId,
    required this.newBadges,
  });

  final int flamesEarned;
  final int streakBonus;
  final int flamesTotal;
  final int streakDays;
  final String? unlockedStageId;
  final String? unlockedLevelId;
  final List<BadgeAwardDto> newBadges;

  factory CompleteStageResponseDto.fromJson(Map<String, dynamic> json) {
    final rawBadges = json['newBadges'] as List?;
    return CompleteStageResponseDto(
      flamesEarned: (json['flamesEarned'] as num?)?.toInt() ?? 0,
      streakBonus: (json['streakBonus'] as num?)?.toInt() ?? 0,
      flamesTotal: (json['flamesTotal'] as num?)?.toInt() ?? 0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      unlockedStageId: json['unlockedStageId'] as String?,
      unlockedLevelId: json['unlockedLevelId'] as String?,
      newBadges: rawBadges == null
          ? const []
          : rawBadges
              .whereType<Map>()
              .map(
                (b) => BadgeAwardDto.fromJson(Map<String, dynamic>.from(b)),
              )
              .toList(),
    );
  }
}

Map<String, dynamic> _decodeJsonMap(dynamic raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is String && raw.trim().startsWith('{')) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return const {};
    }
  }
  return const {};
}

List<dynamic> _decodeJsonList(dynamic raw) {
  if (raw is List) return raw;
  if (raw is String && raw.trim().startsWith('[')) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
    } catch (_) {
      return const [];
    }
  }
  return const [];
}
