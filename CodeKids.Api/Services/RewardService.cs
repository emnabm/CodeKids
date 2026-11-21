using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Rewards;
using CodeKids.Api.Exceptions;
using Microsoft.EntityFrameworkCore;

namespace CodeKids.Api.Services;

public class RewardService : IRewardService
{
    private readonly CodeKidsDbContext _context;
    private readonly IChildService _childService;

    public RewardService(CodeKidsDbContext context, IChildService childService)
    {
        _context = context;
        _childService = childService;
    }

    public async Task<RewardResponseDto> GetRewardsAsync(Guid parentId, Guid childId)
    {
        // 1. Verify ownership (Hard Rule 1)
        var child = await _childService.VerifyOwnershipAsync(parentId, childId);

        // 2. Fetch flame transactions
        var transactions = await _context.FlameTransactions
            .AsNoTracking()
            .Where(t => t.ChildId == childId)
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();

        // 3. Fetch completed progress
        var progresses = await _context.ChildStageProgresses
            .AsNoTracking()
            .Where(p => p.ChildId == childId && p.Completed)
            .ToListAsync();

        // 4. Fetch earned badges
        var badges = await _context.ChildBadges
            .AsNoTracking()
            .Include(cb => cb.Badge)
            .Where(cb => cb.ChildId == childId)
            .OrderByDescending(cb => cb.EarnedAt)
            .Select(cb => new ChildBadgeDto(
                cb.BadgeId,
                cb.Badge.Name,
                cb.Badge.Condition,
                cb.Badge.IconUrl,
                cb.EarnedAt
            ))
            .ToListAsync();

        // 5. Build 7-day activity window (from 6 days ago up to today, UTC)
        var today = DateTime.UtcNow.Date;
        var sevenDayActivity = new List<DayActivityDto>();

        for (int i = 6; i >= 0; i--)
        {
            var day = today.AddDays(-i);
            var dayStr = day.ToString("yyyy-MM-dd");

            var dayFlames = transactions
                .Where(t => t.CreatedAt.Date == day && t.Amount > 0)
                .Sum(t => t.Amount);

            var dayStages = progresses
                .Count(p => p.CompletedAt.HasValue && p.CompletedAt.Value.Date == day);

            var isActive = dayFlames > 0 || dayStages > 0;

            sevenDayActivity.Add(new DayActivityDto(
                Date: dayStr,
                FlamesEarned: dayFlames,
                StagesCompleted: dayStages,
                IsActive: isActive
            ));
        }

        var transactionDtos = transactions.Select(t => new TransactionDto(
            Id: t.Id,
            Amount: t.Amount,
            Reason: t.Reason.ToString(),
            CreatedAt: t.CreatedAt
        )).ToList();

        return new RewardResponseDto(
            Flames: child.Flames,
            StreakDays: child.StreakDays,
            SevenDayActivity: sevenDayActivity,
            Transactions: transactionDtos,
            Badges: badges
        );
    }

    public async Task<StatsResponseDto> GetStatsAsync(Guid parentId, Guid childId)
    {
        // 1. Verify ownership (Hard Rule 1)
        var child = await _childService.VerifyOwnershipAsync(parentId, childId);

        // 2. Fetch parent language
        var parent = await _context.Parents.AsNoTracking().FirstOrDefaultAsync(p => p.Id == parentId);
        var targetLanguage = parent?.Language ?? "en";

        var levels = await _context.Levels
            .AsNoTracking()
            .Include(l => l.Stages)
            .Where(l => l.Language == targetLanguage)
            .OrderBy(l => l.Order)
            .ToListAsync();

        if (levels.Count == 0 && targetLanguage != "en")
        {
            levels = await _context.Levels
                .AsNoTracking()
                .Include(l => l.Stages)
                .Where(l => l.Language == "en")
                .OrderBy(l => l.Order)
                .ToListAsync();
        }

        // 3. Fetch progress and transactions
        var progresses = await _context.ChildStageProgresses
            .AsNoTracking()
            .Where(p => p.ChildId == childId && p.Completed)
            .ToListAsync();

        var completedStageIds = progresses.Select(p => p.StageId).ToHashSet();

        var transactions = await _context.FlameTransactions
            .AsNoTracking()
            .Where(t => t.ChildId == childId)
            .ToListAsync();

        // 4. Calculate 7-day flames per day
        var today = DateTime.UtcNow.Date;
        var flamesPerDay = new List<DailyFlamesDto>();

        for (int i = 6; i >= 0; i--)
        {
            var day = today.AddDays(-i);
            var dayFlames = transactions
                .Where(t => t.CreatedAt.Date == day && t.Amount > 0)
                .Sum(t => t.Amount);

            flamesPerDay.Add(new DailyFlamesDto(
                Date: day.ToString("yyyy-MM-dd"),
                Flames: dayFlames
            ));
        }

        // 5. Calculate progress per level
        var levelProgressList = new List<LevelProgressDto>();

        foreach (var level in levels)
        {
            var totalStages = level.Stages.Count;
            var completedCount = level.Stages.Count(s => completedStageIds.Contains(s.Id));
            var percentage = totalStages > 0 ? Math.Round((double)completedCount / totalStages * 100.0, 1) : 0.0;
            var isCompleted = totalStages > 0 && completedCount == totalStages;

            levelProgressList.Add(new LevelProgressDto(
                LevelId: level.Id,
                LevelOrder: level.Order,
                LevelTitle: level.Title,
                TotalStages: totalStages,
                CompletedStages: completedCount,
                CompletionPercentage: percentage,
                IsCompleted: isCompleted
            ));
        }

        return new StatsResponseDto(
            ChildId: child.Id,
            ChildName: child.Name,
            TotalCompletedStages: completedStageIds.Count,
            TotalFlames: child.Flames,
            CurrentStreakDays: child.StreakDays,
            FlamesPerDay: flamesPerDay,
            LevelProgress: levelProgressList
        );
    }
}
