using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Auth;
using CodeKids.Api.DTOs.Children;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using CodeKids.Api.Models.Enums;
using CodeKids.Api.Services;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace CodeKids.Tests;

public class MapServiceTests
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
    public void ComputeMap_UnlockComputationAcrossLevels_WorksCorrectly()
    {
        // Setup 2 levels, each with 2 stages
        var level1 = new Level
        {
            Id = Guid.NewGuid(),
            Order = 1,
            Title = "Level 1",
            Theme = "Theme 1",
            Language = "en",
            IconUrl = "icon1.png"
        };
        var l1s1 = new Stage { Id = Guid.NewGuid(), LevelId = level1.Id, Order = 1, Title = "L1S1", Type = StageType.Explanation, RewardFlames = 10 };
        var l1s2 = new Stage { Id = Guid.NewGuid(), LevelId = level1.Id, Order = 2, Title = "L1S2", Type = StageType.Quiz, RewardFlames = 25 };
        level1.Stages.Add(l1s1);
        level1.Stages.Add(l1s2);

        var level2 = new Level
        {
            Id = Guid.NewGuid(),
            Order = 2,
            Title = "Level 2",
            Theme = "Theme 2",
            Language = "en",
            IconUrl = "icon2.png"
        };
        var l2s1 = new Stage { Id = Guid.NewGuid(), LevelId = level2.Id, Order = 1, Title = "L2S1", Type = StageType.Explanation, RewardFlames = 10 };
        var l2s2 = new Stage { Id = Guid.NewGuid(), LevelId = level2.Id, Order = 2, Title = "L2S2", Type = StageType.Quiz, RewardFlames = 25 };
        level2.Stages.Add(l2s1);
        level2.Stages.Add(l2s2);

        var levels = new List<Level> { level1, level2 };
        var progressMap = new Dictionary<Guid, ChildStageProgress>();

        // Case 1: Initial state (no stages completed)
        var completed1 = new HashSet<Guid>();
        var result1 = MapService.ComputeMap(levels, completed1, progressMap);

        Assert.False(result1[0].IsLocked); // Level 1 is open
        Assert.Equal("available", result1[0].Stages[0].Status); // L1S1 available
        Assert.Equal("locked", result1[0].Stages[1].Status);    // L1S2 locked
        Assert.True(result1[1].IsLocked);  // Level 2 locked
        Assert.Equal("locked", result1[1].Stages[0].Status);    // L2S1 locked

        // Case 2: L1S1 completed
        var completed2 = new HashSet<Guid> { l1s1.Id };
        var result2 = MapService.ComputeMap(levels, completed2, progressMap);

        Assert.Equal("completed", result2[0].Stages[0].Status); // L1S1 completed
        Assert.Equal("available", result2[0].Stages[1].Status); // L1S2 now available
        Assert.True(result2[1].IsLocked);                       // Level 2 still locked
        Assert.Equal("locked", result2[1].Stages[0].Status);    // L2S1 still locked

        // Case 3: Level 1 fully completed (L1S1 and L1S2 completed)
        var completed3 = new HashSet<Guid> { l1s1.Id, l1s2.Id };
        var result3 = MapService.ComputeMap(levels, completed3, progressMap);

        Assert.Equal("completed", result3[0].Stages[0].Status); // L1S1 completed
        Assert.Equal("completed", result3[0].Stages[1].Status); // L1S2 completed
        Assert.False(result3[1].IsLocked);                      // Level 2 now unlocked!
        Assert.Equal("available", result3[1].Stages[0].Status); // L2S1 now available!
        Assert.Equal("locked", result3[1].Stages[1].Status);    // L2S2 still locked
    }

    [Fact]
    public async Task GetMapForChildAsync_InitialSeededState_Stage1AvailableRestLocked()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);

        var map = await mapService.GetMapForChildAsync(parent.Id, child.Id);

        Assert.Equal(child.Id, map.ChildId);
        Assert.Single(map.Levels);

        var level1 = map.Levels[0];
        Assert.False(level1.IsLocked);
        Assert.Equal(4, level1.Stages.Count);

        // Stage 1 (Explanation) is available
        Assert.Equal("available", level1.Stages[0].Status);
        // Stage 2 (Quiz 1) is locked
        Assert.Equal("locked", level1.Stages[1].Status);
        // Stage 3 (Quiz 2) is locked
        Assert.Equal("locked", level1.Stages[2].Status);
        // Stage 4 (Final) is locked
        Assert.Equal("locked", level1.Stages[3].Status);
    }

    [Fact]
    public async Task GetMapForChildAsync_WrongParent_ThrowsForbiddenException()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent1 = await context.Parents.FirstAsync();
        var child1 = await context.Children.FirstAsync(c => c.ParentId == parent1.Id);

        // Create parent 2
        var parent2 = new Parent
        {
            Email = "otherparent@codekids.com",
            PasswordHash = "hash",
            PinHash = "hash",
            Language = "en"
        };
        context.Parents.Add(parent2);
        await context.SaveChangesAsync();

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);

        // Parent 2 requests map for Parent 1's child -> MUST throw ForbiddenException
        await Assert.ThrowsAsync<ForbiddenException>(() => 
            mapService.GetMapForChildAsync(parent2.Id, child1.Id));
    }

    [Fact]
    public async Task IsStageUnlockedAsync_CorrectlyReportsLockedAndUnlocked()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var child = await context.Children.FirstAsync();
        var stages = await context.Stages.OrderBy(s => s.Order).ToListAsync();

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);

        // Stage 1 is unlocked initially
        Assert.True(await mapService.IsStageUnlockedAsync(child.Id, stages[0].Id));
        // Stage 2 is locked initially
        Assert.False(await mapService.IsStageUnlockedAsync(child.Id, stages[1].Id));

        // Mark Stage 1 as completed
        context.ChildStageProgresses.Add(new ChildStageProgress
        {
            ChildId = child.Id,
            StageId = stages[0].Id,
            Completed = true,
            CompletedAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync();

        // Stage 1 is completed (unlocked)
        Assert.True(await mapService.IsStageUnlockedAsync(child.Id, stages[0].Id));
        // Stage 2 is now unlocked (available)
        Assert.True(await mapService.IsStageUnlockedAsync(child.Id, stages[1].Id));
        // Stage 3 is still locked
        Assert.False(await mapService.IsStageUnlockedAsync(child.Id, stages[2].Id));
    }
}
