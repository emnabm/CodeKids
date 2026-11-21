using CodeKids.Api.Data;
using CodeKids.Api.Models;
using CodeKids.Api.Models.Enums;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace CodeKids.Tests;

public class CascadeRulesTests
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
    public async Task DeletingChild_DeletesProgressTransactionsAndBadges_PreservesContent()
    {
        using var context = CreateInMemoryContext();
        await DbSeeder.SeedAsync(context);

        var child = await context.Children.FirstAsync();
        var stage = await context.Stages.FirstAsync();
        var badge = await context.Badges.FirstAsync();

        // Add progress
        var progress = new ChildStageProgress
        {
            ChildId = child.Id,
            StageId = stage.Id,
            Completed = true,
            CompletedAt = DateTime.UtcNow,
            FlamesEarned = 10
        };
        context.ChildStageProgresses.Add(progress);

        // Add transaction
        var tx = new FlameTransaction
        {
            ChildId = child.Id,
            Amount = 10,
            Reason = FlameReason.StageReward,
            CreatedAt = DateTime.UtcNow
        };
        context.FlameTransactions.Add(tx);

        // Add child badge
        var childBadge = new ChildBadge
        {
            ChildId = child.Id,
            BadgeId = badge.Id,
            EarnedAt = DateTime.UtcNow
        };
        context.ChildBadges.Add(childBadge);

        await context.SaveChangesAsync();

        // Delete the child
        context.Children.Remove(child);
        await context.SaveChangesAsync();

        // Assert: Child and child-specific data deleted
        Assert.Null(await context.Children.FindAsync(child.Id));
        Assert.Empty(await context.ChildStageProgresses.Where(p => p.ChildId == child.Id).ToListAsync());
        Assert.Empty(await context.FlameTransactions.Where(t => t.ChildId == child.Id).ToListAsync());
        Assert.Empty(await context.ChildBadges.Where(cb => cb.ChildId == child.Id).ToListAsync());

        // Assert: Content (Level, Stage, Question, Badge) MUST still exist
        Assert.NotNull(await context.Stages.FindAsync(stage.Id));
        Assert.NotNull(await context.Badges.FindAsync(badge.Id));
        Assert.True(await context.Questions.AnyAsync());
        Assert.True(await context.Levels.AnyAsync());
    }
}
