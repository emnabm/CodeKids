using CodeKids.Api.Data;
using CodeKids.Api.Models.Enums;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace CodeKids.Tests;

public class DbSeederTests
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
    public async Task SeedAsync_SeedsDemoDataAndIsIdempotent()
    {
        using var context = CreateInMemoryContext();

        // Act 1: First seed
        await DbSeeder.SeedAsync(context);

        // Assert 1: Demo parent
        var parent = await context.Parents.Include(p => p.Children).FirstOrDefaultAsync(p => p.Email == "demo@codekids.com");
        Assert.NotNull(parent);
        Assert.True(BCrypt.Net.BCrypt.Verify("Password123!", parent.PasswordHash));
        Assert.True(BCrypt.Net.BCrypt.Verify("1234", parent.PinHash));
        Assert.Single(parent.Children);

        var child = parent.Children.First();
        Assert.Equal("Alex", child.Name);
        Assert.Equal(10, child.Age);

        // Assert 2: Badges
        var badges = await context.Badges.ToListAsync();
        Assert.Equal(5, badges.Count);

        // Assert 3: Level 1 and Stages
        var level = await context.Levels
            .Include(l => l.Stages)
                .ThenInclude(s => s.Questions)
            .FirstOrDefaultAsync(l => l.Order == 1 && l.Language == "en");

        Assert.NotNull(level);
        Assert.Equal(4, level.Stages.Count);

        // Check stages: 1 Explanation, 2 Quizzes, 1 Final
        var stages = level.Stages.OrderBy(s => s.Order).ToList();
        Assert.Equal(StageType.Explanation, stages[0].Type);
        Assert.Equal(10, stages[0].RewardFlames);

        Assert.Equal(StageType.Quiz, stages[1].Type);
        Assert.Equal(25, stages[1].RewardFlames);
        Assert.Equal(4, stages[1].Questions.Count);

        Assert.Equal(StageType.Quiz, stages[2].Type);
        Assert.Equal(25, stages[2].RewardFlames);
        Assert.Equal(4, stages[2].Questions.Count);

        Assert.Equal(StageType.Final, stages[3].Type);
        Assert.Equal(60, stages[3].RewardFlames);
        Assert.Equal(4, stages[3].Questions.Count);

        // Verify question types present
        var allQuestionTypes = stages[1].Questions.Select(q => q.Type).ToHashSet();
        Assert.Contains(QuestionType.Mcq, allQuestionTypes);
        Assert.Contains(QuestionType.TrueFalse, allQuestionTypes);
        Assert.Contains(QuestionType.Order, allQuestionTypes);
        Assert.Contains(QuestionType.FillBlank, allQuestionTypes);

        // Act 2: Run SeedAsync again to test idempotency
        await DbSeeder.SeedAsync(context);

        // Assert 4: Counts must remain identical
        Assert.Equal(1, await context.Parents.CountAsync());
        Assert.Equal(1, await context.Children.CountAsync());
        Assert.Equal(5, await context.Badges.CountAsync());
        Assert.Equal(1, await context.Levels.CountAsync());
        Assert.Equal(4, await context.Stages.CountAsync());
        Assert.Equal(12, await context.Questions.CountAsync());
    }
}
