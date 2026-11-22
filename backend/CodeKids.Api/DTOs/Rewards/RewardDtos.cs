namespace CodeKids.Api.DTOs.Rewards;

public record RewardResponseDto(
    int Flames,
    int StreakDays,
    List<DayActivityDto> SevenDayActivity,
    List<TransactionDto> Transactions,
    List<ChildBadgeDto> Badges
);

public record DayActivityDto(
    string Date,
    int FlamesEarned,
    int StagesCompleted,
    bool IsActive
);

public record TransactionDto(
    Guid Id,
    int Amount,
    string Reason,
    DateTime CreatedAt
);

public record ChildBadgeDto(
    Guid Id,
    string Name,
    string Condition,
    string IconUrl,
    DateTime EarnedAt
);

public record StatsResponseDto(
    Guid ChildId,
    string ChildName,
    int TotalCompletedStages,
    int TotalFlames,
    int CurrentStreakDays,
    List<DailyFlamesDto> FlamesPerDay,
    List<LevelProgressDto> LevelProgress
);

public record DailyFlamesDto(
    string Date,
    int Flames
);

public record LevelProgressDto(
    Guid LevelId,
    int LevelOrder,
    string LevelTitle,
    int TotalStages,
    int CompletedStages,
    double CompletionPercentage,
    bool IsCompleted
);
