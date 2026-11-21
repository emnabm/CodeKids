using System.Text.Json;
using CodeKids.Api.Models;
using CodeKids.Api.Models.Enums;
using Microsoft.EntityFrameworkCore;

namespace CodeKids.Api.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(CodeKidsDbContext context)
    {
        var seedJsonPath = Path.Combine(AppContext.BaseDirectory, "Data", "seedData.json");
        if (!File.Exists(seedJsonPath))
        {
            // Fallback to project relative path if running in dev environment
            seedJsonPath = Path.Combine(Directory.GetCurrentDirectory(), "Data", "seedData.json");
        }

        if (!File.Exists(seedJsonPath))
        {
            throw new FileNotFoundException($"Seed file not found at: {seedJsonPath}");
        }

        var json = await File.ReadAllTextAsync(seedJsonPath);
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;

        // 1. Seed Demo Parent & Demo Child
        if (root.TryGetProperty("demoParent", out var parentElem))
        {
            var email = parentElem.GetProperty("email").GetString()!;
            var password = parentElem.GetProperty("password").GetString()!;
            var pin = parentElem.GetProperty("pin").GetString()!;
            var language = parentElem.GetProperty("language").GetString()!;

            var existingParent = await context.Parents
                .Include(p => p.Children)
                .FirstOrDefaultAsync(p => p.Email == email);

            if (existingParent == null)
            {
                existingParent = new Parent
                {
                    Email = email,
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword(password),
                    PinHash = BCrypt.Net.BCrypt.HashPassword(pin),
                    Language = language,
                    CreatedAtUtc = DateTime.UtcNow
                };

                context.Parents.Add(existingParent);
                await context.SaveChangesAsync();
            }

            // Demo Child
            if (root.TryGetProperty("demoChild", out var childElem))
            {
                var childName = childElem.GetProperty("name").GetString()!;
                var age = childElem.GetProperty("age").GetInt32();
                var avatarId = childElem.GetProperty("avatarId").GetString()!;

                var existingChild = await context.Children
                    .FirstOrDefaultAsync(c => c.ParentId == existingParent.Id && c.Name == childName);

                if (existingChild == null)
                {
                    var child = new Child
                    {
                        ParentId = existingParent.Id,
                        Name = childName,
                        Age = age,
                        AvatarId = avatarId,
                        Flames = 0,
                        StreakDays = 0,
                        LastActiveDate = null
                    };

                    context.Children.Add(child);
                    await context.SaveChangesAsync();
                }
            }
        }

        // 2. Seed Badges
        if (root.TryGetProperty("badges", out var badgesElem))
        {
            foreach (var badgeItem in badgesElem.EnumerateArray())
            {
                var condition = badgeItem.GetProperty("condition").GetString()!;
                var name = badgeItem.GetProperty("name").GetString()!;
                var iconUrl = badgeItem.GetProperty("iconUrl").GetString()!;

                var existingBadge = await context.Badges.FirstOrDefaultAsync(b => b.Condition == condition);
                if (existingBadge == null)
                {
                    context.Badges.Add(new Badge
                    {
                        Name = name,
                        Condition = condition,
                        IconUrl = iconUrl
                    });
                }
            }
            await context.SaveChangesAsync();
        }

        // 3. Seed Levels, Stages, and Questions
        if (root.TryGetProperty("levels", out var levelsElem))
        {
            foreach (var levelItem in levelsElem.EnumerateArray())
            {
                var order = levelItem.GetProperty("order").GetInt32();
                var language = levelItem.GetProperty("language").GetString()!;
                var title = levelItem.GetProperty("title").GetString()!;
                var theme = levelItem.GetProperty("theme").GetString()!;
                var iconUrl = levelItem.GetProperty("iconUrl").GetString()!;

                var existingLevel = await context.Levels
                    .Include(l => l.Stages)
                        .ThenInclude(s => s.Questions)
                    .FirstOrDefaultAsync(l => l.Language == language && l.Order == order);

                if (existingLevel == null)
                {
                    existingLevel = new Level
                    {
                        Order = order,
                        Language = language,
                        Title = title,
                        Theme = theme,
                        IconUrl = iconUrl
                    };
                    context.Levels.Add(existingLevel);
                    await context.SaveChangesAsync();
                }

                if (levelItem.TryGetProperty("stages", out var stagesElem))
                {
                    foreach (var stageItem in stagesElem.EnumerateArray())
                    {
                        var stageOrder = stageItem.GetProperty("order").GetInt32();
                        var typeStr = stageItem.GetProperty("type").GetString()!;
                        var stageType = Enum.Parse<StageType>(typeStr, ignoreCase: true);
                        var stageTitle = stageItem.GetProperty("title").GetString()!;
                        var rewardFlames = stageItem.GetProperty("rewardFlames").GetInt32();
                        var contentRaw = stageItem.GetProperty("content").GetRawText();

                        var existingStage = existingLevel.Stages.FirstOrDefault(s => s.Order == stageOrder);
                        if (existingStage == null)
                        {
                            existingStage = new Stage
                            {
                                LevelId = existingLevel.Id,
                                Order = stageOrder,
                                Type = stageType,
                                Title = stageTitle,
                                RewardFlames = rewardFlames,
                                ContentJson = contentRaw
                            };
                            context.Stages.Add(existingStage);
                            await context.SaveChangesAsync();
                        }

                        if (stageItem.TryGetProperty("questions", out var questionsElem))
                        {
                            var existingQuestions = await context.Questions
                                .Where(q => q.StageId == existingStage.Id)
                                .ToListAsync();

                            if (existingQuestions.Count == 0)
                            {
                                foreach (var qItem in questionsElem.EnumerateArray())
                                {
                                    var qTypeStr = qItem.GetProperty("type").GetString()!;
                                    var qType = Enum.Parse<QuestionType>(qTypeStr, ignoreCase: true);
                                    var text = qItem.GetProperty("text").GetString()!;
                                    var optionsRaw = qItem.GetProperty("options").GetRawText();
                                    var answerRaw = qItem.GetProperty("answer").GetRawText();
                                    var hintText = qItem.GetProperty("hintText").GetString()!;
                                    var explanationText = qItem.GetProperty("explanationText").GetString()!;

                                    var question = new Question
                                    {
                                        StageId = existingStage.Id,
                                        Type = qType,
                                        Text = text,
                                        OptionsJson = optionsRaw,
                                        AnswerJson = answerRaw,
                                        HintText = hintText,
                                        ExplanationText = explanationText
                                    };
                                    context.Questions.Add(question);
                                }
                                await context.SaveChangesAsync();
                            }
                        }
                    }
                }
            }
        }
    }
}
