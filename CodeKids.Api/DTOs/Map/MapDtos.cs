namespace CodeKids.Api.DTOs.Map;

public record MapResponseDto(
    Guid ChildId,
    string ChildName,
    int Flames,
    int StreakDays,
    List<MapLevelDto> Levels
);

public record MapLevelDto(
    Guid Id,
    int Order,
    string Title,
    string Theme,
    string IconUrl,
    bool IsLocked,
    List<MapStageDto> Stages
);

public record MapStageDto(
    Guid Id,
    int Order,
    string Type,
    string Title,
    int RewardFlames,
    string Status, // "locked" | "available" | "completed"
    int FlamesEarned,
    int Attempts
);
