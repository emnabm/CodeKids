using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Stages;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using CodeKids.Api.Models.Enums;
using CodeKids.Api.Services;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace CodeKids.Tests;

public class HintServiceTests
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
    public void CalculateHintCost_ProgressionIncreasesByFiftyEachTime()
    {
        Assert.Equal(100, HintService.CalculateHintCost(0)); // 1st hint
        Assert.Equal(150, HintService.CalculateHintCost(1)); // 2nd hint
        Assert.Equal(200, HintService.CalculateHintCost(2)); // 3rd hint
        Assert.Equal(250, HintService.CalculateHintCost(3)); // 4th hint
    }

    [Fact]
    public async Task PurchaseHintAsync_InsufficientFlames_ThrowsInsufficientFlamesException()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var question = await context.Questions.FirstAsync();

        // Unlock stage containing question by completing stage 1
        var stage1 = await context.Stages.OrderBy(s => s.Order).FirstAsync();
        context.ChildStageProgresses.Add(new ChildStageProgress
        {
            ChildId = child.Id,
            StageId = stage1.Id,
            Completed = true,
            CompletedAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync();

        // Child has 0 flames initially, 1st hint costs 100
        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);
        var hintService = new HintService(context, childService, mapService);

        var request = new HintRequestDto(child.Id, question.Id);

        var ex = await Assert.ThrowsAsync<InsufficientFlamesException>(() =>
            hintService.PurchaseHintAsync(parent.Id, question.StageId, request));

        Assert.Equal(409, ex.StatusCode);
    }

    [Fact]
    public async Task PurchaseHintAsync_SufficientFlames_DebitsBalanceRecordsTransactionAndEnforcesInvariant()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent = await context.Parents.FirstAsync();
        var child = await context.Children.FirstAsync(c => c.ParentId == parent.Id);
        var question = await context.Questions.FirstAsync();

        // Unlock stage containing question by completing stage 1
        var stage1 = await context.Stages.OrderBy(s => s.Order).FirstAsync();
        context.ChildStageProgresses.Add(new ChildStageProgress
        {
            ChildId = child.Id,
            StageId = stage1.Id,
            Completed = true,
            CompletedAt = DateTime.UtcNow
        });

        // Give child initial 500 flames with an initial transaction
        child.Flames = 500;
        context.FlameTransactions.Add(new FlameTransaction
        {
            ChildId = child.Id,
            Amount = 500,
            Reason = FlameReason.StageReward,
            CreatedAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync();

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);
        var hintService = new HintService(context, childService, mapService);

        // 1st Hint: costs 100
        var resp1 = await hintService.PurchaseHintAsync(parent.Id, question.StageId, new HintRequestDto(child.Id, question.Id));
        Assert.Equal(100, resp1.Cost);
        Assert.Equal(400, resp1.FlamesLeft);
        Assert.Equal(question.HintText, resp1.HintText);

        // 2nd Hint: costs 150
        var resp2 = await hintService.PurchaseHintAsync(parent.Id, question.StageId, new HintRequestDto(child.Id, question.Id));
        Assert.Equal(150, resp2.Cost);
        Assert.Equal(250, resp2.FlamesLeft);

        // Verify Invariant: Child.Flames always equals sum of FlameTransactions
        var totalTransactions = await context.FlameTransactions
            .Where(t => t.ChildId == child.Id)
            .SumAsync(t => t.Amount);

        var refreshedChild = await context.Children.FindAsync(child.Id);
        Assert.Equal(250, refreshedChild!.Flames);
        Assert.Equal(refreshedChild.Flames, totalTransactions);
    }

    [Fact]
    public async Task PurchaseHintAsync_WrongParent_ThrowsForbiddenException()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var parent1 = await context.Parents.FirstAsync();
        var child1 = await context.Children.FirstAsync(c => c.ParentId == parent1.Id);
        var question = await context.Questions.FirstAsync();

        var parent2 = new Parent
        {
            Email = "intruder@codekids.com",
            PasswordHash = "h",
            PinHash = "h",
            Language = "en"
        };
        context.Parents.Add(parent2);
        await context.SaveChangesAsync();

        var childService = new ChildService(context);
        var mapService = new MapService(context, childService);
        var hintService = new HintService(context, childService, mapService);

        await Assert.ThrowsAsync<ForbiddenException>(() =>
            hintService.PurchaseHintAsync(parent2.Id, question.StageId, new HintRequestDto(child1.Id, question.Id)));
    }
}
