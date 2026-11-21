using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Stages;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models.Enums;
using CodeKids.Api.Services;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace CodeKids.Tests;

public class StageServiceTests
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
    public async Task CompleteStageAsync_FirstTime_GrantsFlamesStreakAndBadges()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var stage1 = await context.Stages.OrderBy(s => s.Order).FirstAsync(); // Explanation: 10 flames

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);
        var streakService = new StreakService();
        var stageService = new StageService(context, childService, mapService, streakService);

        var request = new CompleteStageRequestDto(child.Id, HintsUsed: 0, Attempts: 1);
        var response = await stageService.CompleteStageAsync(parent.Id, stage1.Id, request);

        // Stage 1 Reward = 10, Streak Bonus Day 1 = 5 -> Total = 15
        Assert.Equal(10, response.FlamesEarned);
        Assert.Equal(5, response.StreakBonus);
        Assert.Equal(15, response.FlamesTotal);
        Assert.Equal(1, response.StreakDays);
        Assert.NotNull(response.UnlockedStageId);

        // Verify First Stage Badge awarded
        Assert.Contains(response.NewBadges, b => b.Condition == "FIRST_STAGE");

        // Verify Invariant: Child.Flames equals sum of FlameTransactions
        var totalTransactions = await context.FlameTransactions
            .Where(t => t.ChildId == child.Id)
            .SumAsync(t => t.Amount);

        var refreshedChild = await context.Children.FindAsync(child.Id);
        Assert.Equal(15, refreshedChild!.Flames);
        Assert.Equal(15, totalTransactions);
    }

    [Fact]
    public async Task CompleteStageAsync_Idempotent_ReplayGivesNoFlamesOrDuplicateBonus()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var stage1 = await context.Stages.OrderBy(s => s.Order).FirstAsync();

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);
        var streakService = new StreakService();
        var stageService = new StageService(context, childService, mapService, streakService);

        var request = new CompleteStageRequestDto(child.Id, HintsUsed: 0, Attempts: 1);

        // 1st Completion
        var firstResponse = await stageService.CompleteStageAsync(parent.Id, stage1.Id, request);
        Assert.Equal(10, firstResponse.FlamesEarned);
        Assert.Equal(15, firstResponse.FlamesTotal);

        // 2nd Completion (Idempotent Replay)
        var secondResponse = await stageService.CompleteStageAsync(parent.Id, stage1.Id, request);
        Assert.Equal(0, secondResponse.FlamesEarned);
        Assert.Equal(0, secondResponse.StreakBonus);
        Assert.Equal(15, secondResponse.FlamesTotal); // Unchanged! Calling twice never doubles flames.
        Assert.Empty(secondResponse.NewBadges);

        // Verify Invariant holds: total transactions still 15
        var totalTransactions = await context.FlameTransactions
            .Where(t => t.ChildId == child.Id)
            .SumAsync(t => t.Amount);

        Assert.Equal(15, totalTransactions);
    }

    [Fact]
    public async Task CompleteStageAsync_LockedStage_RejectsWithValidationException()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var stages = await context.Stages.OrderBy(s => s.Order).ToListAsync();
        var stage2 = stages[1]; // Stage 2 is locked because Stage 1 is not yet completed

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);
        var streakService = new StreakService();
        var stageService = new StageService(context, childService, mapService, streakService);

        var request = new CompleteStageRequestDto(child.Id, HintsUsed: 0, Attempts: 1);

        // Attempting to complete locked Stage 2 must be rejected
        await Assert.ThrowsAsync<ValidationException>(() =>
            stageService.CompleteStageAsync(parent.Id, stage2.Id, request));

        // Attempting to access content of locked Stage 2 must be rejected
        await Assert.ThrowsAsync<ValidationException>(() =>
            stageService.GetStageContentAsync(parent.Id, stage2.Id, child.Id));
    }

    [Fact]
    public async Task GetStageContentAsync_AvailableStage_ReturnsStructuredQuestions()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var stages = await context.Stages.OrderBy(s => s.Order).ToListAsync();
        var stage1 = stages[0]; // Stage 1 is available

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);
        var streakService = new StreakService();
        var stageService = new StageService(context, childService, mapService, streakService);

        var result = await stageService.GetStageContentAsync(parent.Id, stage1.Id, child.Id);

        Assert.NotNull(result);
        Assert.Equal(stage1.Id, result.Id);
        Assert.Equal("Explanation", result.Type);
        Assert.Equal(10, result.RewardFlames);
    }
}
