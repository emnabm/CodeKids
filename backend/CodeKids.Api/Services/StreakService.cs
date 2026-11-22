namespace CodeKids.Api.Services;

public class StreakService : IStreakService
{
    public StreakCalculationResult CalculateStreak(int currentStreak, DateTime? lastActiveDateUtc, DateTime nowUtc)
    {
        return Calculate(currentStreak, lastActiveDateUtc, nowUtc);
    }

    /// <summary>
    /// Pure method for calculating streak days and bonus flames based on UTC dates.
    /// Rules:
    /// - First day: streak = 1, bonus = 5.
    /// - Same day: no change in streak, no second bonus (bonus = 0).
    /// - Next consecutive day: streak = streak + 1, bonus = min(streak * 5, 50).
    /// - Skipped day: streak resets to 1, bonus = 5.
    /// </summary>
    public static StreakCalculationResult Calculate(int currentStreak, DateTime? lastActiveDateUtc, DateTime nowUtc)
    {
        var today = DateOnly.FromDateTime(nowUtc.Date);

        if (!lastActiveDateUtc.HasValue)
        {
            var newStreak = 1;
            var bonus = Math.Min(newStreak * 5, 50);
            return new StreakCalculationResult(newStreak, bonus, true, nowUtc);
        }

        var lastActiveDate = DateOnly.FromDateTime(lastActiveDateUtc.Value.Date);

        if (today == lastActiveDate)
        {
            // Same day: no change, no second bonus
            return new StreakCalculationResult(currentStreak, 0, false, lastActiveDateUtc.Value);
        }

        if (today == lastActiveDate.AddDays(1))
        {
            // Consecutive day: streak increases by 1, bonus is +5 per day up to +50
            var newStreak = currentStreak + 1;
            var bonus = Math.Min(newStreak * 5, 50);
            return new StreakCalculationResult(newStreak, bonus, true, nowUtc);
        }

        if (today > lastActiveDate.AddDays(1))
        {
            // Skipped day: reset streak to 1
            var newStreak = 1;
            var bonus = Math.Min(newStreak * 5, 50);
            return new StreakCalculationResult(newStreak, bonus, true, nowUtc);
        }

        // Clock skew backwards fallback
        return new StreakCalculationResult(currentStreak, 0, false, lastActiveDateUtc.Value);
    }
}
