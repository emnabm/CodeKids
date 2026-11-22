using System.Text.Json;
using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Stages;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using CodeKids.Api.Models.Enums;
using Microsoft.EntityFrameworkCore;

namespace CodeKids.Api.Services;

public class StageService : IStageService
{
    private readonly CodeKidsDbContext _context;
    private readonly IChildService _childService;
    private readonly IMapService _mapService;
    private readonly IStreakService _streakService;

    public StageService(
        CodeKidsDbContext context,
        IChildService childService,
        IMapService mapService,
        IStreakService streakService)
    {
        _context = context;
        _childService = childService;
        _mapService = mapService;
        _streakService = streakService;
    }

    public async Task<StageDetailDto> GetStageContentAsync(Guid parentId, Guid stageId, Guid childId)
    {
        // 1. Verify ownership (Hard Rule 1)
        var child = await _childService.VerifyOwnershipAsync(parentId, childId);

        // 2. Fetch stage and questions
        var stage = await _context.Stages
            .Include(s => s.Questions)
            .FirstOrDefaultAsync(s => s.Id == stageId);

        if (stage == null)
        {
            throw new NotFoundException($"Stage with ID '{stageId}' was not found.");
        }

        // 3. Reject locked stages
        var isUnlocked = await _mapService.IsStageUnlockedAsync(child.Id, stageId);
        if (!isUnlocked)
        {
            throw new ValidationException("Cannot access content of a locked stage.");
        }

        // 4. Map questions with proper JSON elements
        var questionDtos = stage.Questions.Select(q =>
        {
            var options = JsonDocument.Parse(q.OptionsJson).RootElement.Clone();
            var answer = JsonDocument.Parse(q.AnswerJson).RootElement.Clone();

            return new StageQuestionDto(
                Id: q.Id,
                Type: q.Type.ToString(),
                Text: q.Text,
                Options: options,
                Answer: answer,
                HintText: q.HintText,
                ExplanationText: q.ExplanationText
            );
        }).ToList();

        var content = JsonDocument.Parse(stage.ContentJson).RootElement.Clone();

        return new StageDetailDto(
            Id: stage.Id,
            LevelId: stage.LevelId,
            Order: stage.Order,
            Type: stage.Type.ToString(),
            Title: stage.Title,
            RewardFlames: stage.RewardFlames,
            Content: content,
            Questions: questionDtos
        );
    }

    public async Task<CompleteStageResponseDto> CompleteStageAsync(Guid parentId, Guid stageId, CompleteStageRequestDto request)
    {
        // 1. Verify ownership (Hard Rule 1: 403 if not owned, 404 if child not found)
        var child = await _childService.VerifyOwnershipAsync(parentId, request.ChildId);

        // 2. Verify stage exists
        var stage = await _context.Stages
            .Include(s => s.Level)
            .FirstOrDefaultAsync(s => s.Id == stageId);

        if (stage == null)
        {
            throw new NotFoundException($"Stage with ID '{stageId}' was not found.");
        }

        // 3. Reject locked stages (Hard Rule 2)
        var isUnlocked = await _mapService.IsStageUnlockedAsync(child.Id, stageId);
        if (!isUnlocked)
        {
            throw new ValidationException("Cannot complete a locked stage.");
        }

        var progress = await _context.ChildStageProgresses
            .FirstOrDefaultAsync(p => p.ChildId == child.Id && p.StageId == stageId);

        // 4. Hard Rule 2: IDEMPOTENCY check (Calling twice never doubles flames or grants repeat rewards)
        if (progress != null && progress.Completed)
        {
            // Replaying is allowed, but gives NO flames and NO streak bonus
            progress.Attempts += request.Attempts;
            progress.HintsUsed = Math.Max(progress.HintsUsed, request.HintsUsed);
            await _context.SaveChangesAsync();

            var (nextStageIdReplay, nextLevelIdReplay) = await FindNextUnlockedAsync(stage);

            return new CompleteStageResponseDto(
                FlamesEarned: 0,
                StreakBonus: 0,
                FlamesTotal: child.Flames,
                StreakDays: child.StreakDays,
                UnlockedStageId: nextStageIdReplay,
                UnlockedLevelId: nextLevelIdReplay,
                NewBadges: new List<BadgeAwardDto>()
            );
        }

        // 5. First-time completion: Execute in ONE database transaction (Hard Rule 2)
        using var transaction = await _context.Database.BeginTransactionAsync();

        // Calculate streak and streak bonus (pure method, UTC dates)
        var streakResult = _streakService.CalculateStreak(child.StreakDays, child.LastActiveDate, DateTime.UtcNow);
        child.StreakDays = streakResult.NewStreakDays;
        child.LastActiveDate = streakResult.UpdatedLastActiveUtc;

        var stageFlames = stage.RewardFlames;
        var streakBonus = streakResult.StreakBonus;
        var totalFlamesAdded = stageFlames + streakBonus;

        // Update child flames balance
        child.Flames += totalFlamesAdded;

        // Record FlameTransaction rows
        var stageTx = new FlameTransaction
        {
            ChildId = child.Id,
            Amount = stageFlames,
            Reason = FlameReason.StageReward,
            CreatedAt = DateTime.UtcNow
        };
        _context.FlameTransactions.Add(stageTx);

        if (streakBonus > 0)
        {
            var streakTx = new FlameTransaction
            {
                ChildId = child.Id,
                Amount = streakBonus,
                Reason = FlameReason.StreakBonus,
                CreatedAt = DateTime.UtcNow
            };
            _context.FlameTransactions.Add(streakTx);
        }

        // Update or create progress
        if (progress == null)
        {
            progress = new ChildStageProgress
            {
                ChildId = child.Id,
                StageId = stageId,
                Completed = true,
                CompletedAt = DateTime.UtcNow,
                Attempts = request.Attempts,
                HintsUsed = request.HintsUsed,
                FlamesEarned = stageFlames
            };
            _context.ChildStageProgresses.Add(progress);
        }
        else
        {
            progress.Completed = true;
            progress.CompletedAt = DateTime.UtcNow;
            progress.Attempts += request.Attempts;
            progress.HintsUsed = Math.Max(progress.HintsUsed, request.HintsUsed);
            progress.FlamesEarned = stageFlames;
        }

        await _context.SaveChangesAsync();

        // 6. Evaluate Badges within transaction
        var newBadges = await EvaluateAndAwardBadgesAsync(child, stage);

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        // 7. Compute next unlocked stage and level
        var (unlockedStageId, unlockedLevelId) = await FindNextUnlockedAsync(stage);

        return new CompleteStageResponseDto(
            FlamesEarned: stageFlames,
            StreakBonus: streakBonus,
            FlamesTotal: child.Flames,
            StreakDays: child.StreakDays,
            UnlockedStageId: unlockedStageId,
            UnlockedLevelId: unlockedLevelId,
            NewBadges: newBadges
        );
    }

    private async Task<(Guid? StageId, Guid? LevelId)> FindNextUnlockedAsync(Stage currentStage)
    {
        // Next stage in same level
        var nextStageInLevel = await _context.Stages
            .Where(s => s.LevelId == currentStage.LevelId && s.Order == currentStage.Order + 1)
            .FirstOrDefaultAsync();

        if (nextStageInLevel != null)
        {
            return (nextStageInLevel.Id, currentStage.LevelId);
        }

        // Next level's first stage
        var nextLevel = await _context.Levels
            .Include(l => l.Stages)
            .Where(l => l.Language == currentStage.Level.Language && l.Order == currentStage.Level.Order + 1)
            .FirstOrDefaultAsync();

        var firstStageOfNextLevel = nextLevel?.Stages.OrderBy(s => s.Order).FirstOrDefault();
        return (firstStageOfNextLevel?.Id, nextLevel?.Id);
    }

    private async Task<List<BadgeAwardDto>> EvaluateAndAwardBadgesAsync(Child child, Stage currentStage)
    {
        var newlyAwarded = new List<BadgeAwardDto>();

        var earnedBadgeIds = (await _context.ChildBadges
            .Where(cb => cb.ChildId == child.Id)
            .Select(cb => cb.BadgeId)
            .ToListAsync()).ToHashSet();

        var allBadges = await _context.Badges.ToListAsync();

        foreach (var badge in allBadges)
        {
            if (earnedBadgeIds.Contains(badge.Id))
                continue;

            bool isEarned = false;

            switch (badge.Condition)
            {
                case "FIRST_STAGE":
                    // Child has just completed a stage
                    isEarned = true;
                    break;

                case "FIRST_QUIZ":
                    // Stage is a Quiz or Final
                    if (currentStage.Type == StageType.Quiz || currentStage.Type == StageType.Final)
                    {
                        isEarned = true;
                    }
                    break;

                case "LEVEL_1_COMPLETE":
                    if (currentStage.Level.Order == 1)
                    {
                        var totalStagesInLevel = await _context.Stages
                            .CountAsync(s => s.LevelId == currentStage.LevelId);

                        var completedStagesInLevel = await _context.ChildStageProgresses
                            .CountAsync(p => p.ChildId == child.Id && p.Completed && p.Stage.LevelId == currentStage.LevelId);

                        if (completedStagesInLevel >= totalStagesInLevel)
                        {
                            isEarned = true;
                        }
                    }
                    break;

                case "STREAK_3":
                    if (child.StreakDays >= 3)
                    {
                        isEarned = true;
                    }
                    break;

                case "STREAK_7":
                    if (child.StreakDays >= 7)
                    {
                        isEarned = true;
                    }
                    break;
            }

            if (isEarned)
            {
                _context.ChildBadges.Add(new ChildBadge
                {
                    ChildId = child.Id,
                    BadgeId = badge.Id,
                    EarnedAt = DateTime.UtcNow
                });

                newlyAwarded.Add(new BadgeAwardDto(
                    badge.Id,
                    badge.Name,
                    badge.Condition,
                    badge.IconUrl
                ));
            }
        }

        return newlyAwarded;
    }
}
