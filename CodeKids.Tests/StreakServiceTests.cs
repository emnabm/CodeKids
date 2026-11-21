using CodeKids.Api.Services;
using Xunit;

namespace CodeKids.Tests;

public class StreakServiceTests
{
    private readonly StreakService _streakService = new();

    [Fact]
    public void CalculateStreak_FirstDay_SetsStreakToOneAndBonusToFive()
    {
        var now = new DateTime(2026, 11, 21, 10, 0, 0, DateTimeKind.Utc);
        var result = _streakService.CalculateStreak(0, null, now);

        Assert.Equal(1, result.NewStreakDays);
        Assert.Equal(5, result.StreakBonus);
        Assert.True(result.IsBonusEligible);
        Assert.Equal(now, result.UpdatedLastActiveUtc);
    }

    [Fact]
    public void CalculateStreak_SameDay_NoStreakChangeAndNoSecondBonus()
    {
        var lastActive = new DateTime(2026, 11, 21, 8, 30, 0, DateTimeKind.Utc);
        var now = new DateTime(2026, 11, 21, 18, 0, 0, DateTimeKind.Utc);

        var result = _streakService.CalculateStreak(3, lastActive, now);

        Assert.Equal(3, result.NewStreakDays);
        Assert.Equal(0, result.StreakBonus);
        Assert.False(result.IsBonusEligible);
    }

    [Fact]
    public void CalculateStreak_ConsecutiveNextDay_IncreasesStreakAndCalculatesBonus()
    {
        var lastActive = new DateTime(2026, 11, 20, 20, 0, 0, DateTimeKind.Utc);
        var now = new DateTime(2026, 11, 21, 10, 0, 0, DateTimeKind.Utc);

        var result = _streakService.CalculateStreak(2, lastActive, now);

        Assert.Equal(3, result.NewStreakDays);
        Assert.Equal(15, result.StreakBonus); // 3 * 5 = 15
        Assert.True(result.IsBonusEligible);
    }

    [Fact]
    public void CalculateStreak_ConsecutiveNextDay_CapsBonusAtFifty()
    {
        var lastActive = new DateTime(2026, 11, 20, 20, 0, 0, DateTimeKind.Utc);
        var now = new DateTime(2026, 11, 21, 10, 0, 0, DateTimeKind.Utc);

        // Day 10 -> day 11 (11 * 5 = 55, capped at 50)
        var result = _streakService.CalculateStreak(10, lastActive, now);

        Assert.Equal(11, result.NewStreakDays);
        Assert.Equal(50, result.StreakBonus);
        Assert.True(result.IsBonusEligible);
    }

    [Fact]
    public void CalculateStreak_SkippedDay_ResetsStreakToOneAndGrantsFiveBonus()
    {
        var lastActive = new DateTime(2026, 11, 18, 10, 0, 0, DateTimeKind.Utc);
        var now = new DateTime(2026, 11, 21, 10, 0, 0, DateTimeKind.Utc); // 3 days later

        var result = _streakService.CalculateStreak(5, lastActive, now);

        Assert.Equal(1, result.NewStreakDays);
        Assert.Equal(5, result.StreakBonus);
        Assert.True(result.IsBonusEligible);
    }
}
