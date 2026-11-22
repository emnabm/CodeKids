namespace CodeKids.Api.Services;

public record StreakCalculationResult(
    int NewStreakDays,
    int StreakBonus,
    bool IsBonusEligible,
    DateTime UpdatedLastActiveUtc
);

public interface IStreakService
{
    StreakCalculationResult CalculateStreak(int currentStreak, DateTime? lastActiveDateUtc, DateTime nowUtc);
}
