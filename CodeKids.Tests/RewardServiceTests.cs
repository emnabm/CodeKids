using CodeKids.Api.Data;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using CodeKids.Api.Models.Enums;
using CodeKids.Api.Services;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace CodeKids.Tests;

public class RewardServiceTests
{
    private CodeKidsDbContext CreateInMemoryContext()
    {
        var connection = new SqliteConnection("DataSource=:memory:");
        connection.Open();

        var options = new DbContextOptionsBuilder<CodeKidsDbContext>()
            .UseSqlite(connection)
            .Options;

        var context = new CodeKidsDbContext(options);
        context.Database.EnsureCreated();
        return context;
    }

    [Fact]
    public async Task GetRewardsAsync_ReturnsSevenDayActivityTransactionsAndBadges()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var badge = await context.Badges.FirstAsync();

        // Add some activity
        child.Flames = 35;
        child.StreakDays = 2;

        context.FlameTransactions.Add(new FlameTransaction
        {
            ChildId = child.Id,
            Amount = 25,
            Reason = FlameReason.StageReward,
            CreatedAt = DateTime.UtcNow
        });
        context.FlameTransactions.Add(new FlameTransaction
        {
            ChildId = child.Id,
            Amount = 10,
            Reason = FlameReason.StreakBonus,
            CreatedAt = DateTime.UtcNow
        });

        context.ChildBadges.Add(new ChildBadge
        {
            ChildId = child.Id,
            BadgeId = badge.Id,
            EarnedAt = DateTime.UtcNow
        });

        await context.SaveChangesAsync();

        var childService = new ChildService(context);
        var rewardService = new RewardService(context, childService);

        var response = await rewardService.GetRewardsAsync(parent.Id, child.Id);

        Assert.Equal(35, response.Flames);
        Assert.Equal(2, response.StreakDays);
        Assert.Equal(7, response.SevenDayActivity.Count);
        Assert.Equal(2, response.Transactions.Count);
        Assert.Single(response.Badges);
        Assert.Equal(badge.Name, response.Badges[0].Name);

        // Today's activity check
        var todayActivity = response.SevenDayActivity.Last();
        Assert.Equal(35, todayActivity.FlamesEarned);
        Assert.True(todayActivity.IsActive);
    }

    [Fact]
    public async Task GetStatsAsync_ReturnsAccurateLevelProgressAndDailyFlames()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var stage1 = await context.Stages.OrderBy(s => s.Order).FirstAsync();

        // Mark 1 of 4 stages completed
        child.Flames = 15;
        child.StreakDays = 1;

        context.ChildStageProgresses.Add(new ChildStageProgress
        {
            ChildId = child.Id,
            StageId = stage1.Id,
            Completed = true,
            CompletedAt = DateTime.UtcNow,
            FlamesEarned = 10
        });

        context.FlameTransactions.Add(new FlameTransaction
        {
            ChildId = child.Id,
            Amount = 15,
            Reason = FlameReason.StageReward,
            CreatedAt = DateTime.UtcNow
        });

        await context.SaveChangesAsync();

        var childService = new ChildService(context);
        var rewardService = new RewardService(context, childService);

        var stats = await rewardService.GetStatsAsync(parent.Id, child.Id);

        Assert.Equal(child.Id, stats.ChildId);
        Assert.Equal(1, stats.TotalCompletedStages);
        Assert.Equal(15, stats.TotalFlames);
        Assert.Equal(1, stats.CurrentStreakDays);
        Assert.Equal(7, stats.FlamesPerDay.Count);

        // Check Level Progress: 1 out of 4 stages = 25.0%
        Assert.Single(stats.LevelProgress);
        var levelProgress = stats.LevelProgress[0];
        Assert.Equal(4, levelProgress.TotalStages);
        Assert.Equal(1, levelProgress.CompletedStages);
        Assert.Equal(25.0, levelProgress.CompletionPercentage);
        Assert.False(levelProgress.IsCompleted);
    }

    [Fact]
    public async Task GetRewardsAsync_WrongParent_ThrowsForbiddenException()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent1 = await context.Parents.FirstAsync();
        var child1 = await context.Children.FirstAsync(c => c.ParentId == parent1.Id);

        var parent2 = new Parent { Email = "stranger@test.com", PasswordHash = "h", PinHash = "p", Language = "en" };
        context.Parents.Add(parent2);
        await context.SaveChangesAsync();

        var childService = new ChildService(context);
        var rewardService = new RewardService(context, childService);

        await Assert.ThrowsAsync<ForbiddenException>(() =>
            rewardService.GetRewardsAsync(parent2.Id, child1.Id));

        await Assert.ThrowsAsync<ForbiddenException>(() =>
            rewardService.GetStatsAsync(parent2.Id, child1.Id));
    }
}
