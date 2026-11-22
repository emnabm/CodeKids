using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace CodeKids.Api.DTOs.Stages;

public record StageDetailDto(
    Guid Id,
    Guid LevelId,
    int Order,
    string Type,
    string Title,
    int RewardFlames,
    JsonElement Content,
    List<StageQuestionDto> Questions
);

public record StageQuestionDto(
    Guid Id,
    string Type,
    string Text,
    JsonElement Options,
    JsonElement Answer,
    string HintText,
    string ExplanationText
);

public record HintRequestDto(
    [Required] Guid ChildId,
    [Required] Guid QuestionId
);

public record HintResponseDto(
    string HintText,
    int Cost,
    int FlamesLeft
);

public record CompleteStageRequestDto(
    [Required] Guid ChildId,
    [Range(0, 100)] int HintsUsed = 0,
    [Range(1, 100)] int Attempts = 1
);

public record CompleteStageResponseDto(
    int FlamesEarned,
    int StreakBonus,
    int FlamesTotal,
    int StreakDays,
    Guid? UnlockedStageId,
    Guid? UnlockedLevelId,
    List<BadgeAwardDto> NewBadges
);

public record BadgeAwardDto(
    Guid Id,
    string Name,
    string Condition,
    string IconUrl
);
