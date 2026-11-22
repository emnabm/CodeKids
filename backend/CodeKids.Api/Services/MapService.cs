using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Map;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CodeKids.Api.Services;

public class MapService : IMapService
{
    private readonly CodeKidsDbContext _context;
    private readonly IChildService _childService;

    public MapService(CodeKidsDbContext context, IChildService childService)
    {
        _context = context;
        _childService = childService;
    }

    public async Task<MapResponseDto> GetMapForChildAsync(Guid parentId, Guid childId)
    {
        // 1. Verify ownership (Hard Rule 1: 403 if not owned, 404 if not found)
        var child = await _childService.VerifyOwnershipAsync(parentId, childId);

        // 2. Determine language from parent with fallback to English
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
            // Fallback to "en"
            levels = await _context.Levels
                .AsNoTracking()
                .Include(l => l.Stages)
                .Where(l => l.Language == "en")
                .OrderBy(l => l.Order)
                .ToListAsync();
        }

        // 3. Fetch progress for this child
        var progresses = await _context.ChildStageProgresses
            .AsNoTracking()
            .Where(p => p.ChildId == childId)
            .ToListAsync();

        var completedStageIds = progresses
            .Where(p => p.Completed)
            .Select(p => p.StageId)
            .ToHashSet();

        var progressMap = progresses.ToDictionary(p => p.StageId, p => p);

        // 4. Compute unlock status
        var computedLevels = ComputeMap(levels, completedStageIds, progressMap);

        return new MapResponseDto(
            ChildId: child.Id,
            ChildName: child.Name,
            Flames: child.Flames,
            StreakDays: child.StreakDays,
            Levels: computedLevels
        );
    }

    public async Task<bool> IsStageUnlockedAsync(Guid childId, Guid stageId)
    {
        var targetStage = await _context.Stages
            .Include(s => s.Level)
            .FirstOrDefaultAsync(s => s.Id == stageId);

        if (targetStage == null)
        {
            throw new NotFoundException($"Stage with ID '{stageId}' was not found.");
        }

        var allLevels = await _context.Levels
            .AsNoTracking()
            .Include(l => l.Stages)
            .Where(l => l.Language == targetStage.Level.Language)
            .OrderBy(l => l.Order)
            .ToListAsync();

        var progresses = await _context.ChildStageProgresses
            .AsNoTracking()
            .Where(p => p.ChildId == childId)
            .ToListAsync();

        var completedStageIds = progresses
            .Where(p => p.Completed)
            .Select(p => p.StageId)
            .ToHashSet();

        var progressMap = progresses.ToDictionary(p => p.StageId, p => p);
        var computedLevels = ComputeMap(allLevels, completedStageIds, progressMap);

        var stageDto = computedLevels
            .SelectMany(l => l.Stages)
            .FirstOrDefault(s => s.Id == stageId);

        return stageDto != null && (stageDto.Status == "available" || stageDto.Status == "completed");
    }

    /// <summary>
    /// Pure computation method for unlocking levels and stages.
    /// Unlocking is COMPUTED, never stored.
    /// </summary>
    public static List<MapLevelDto> ComputeMap(
        List<Level> levels, 
        HashSet<Guid> completedStageIds, 
        Dictionary<Guid, ChildStageProgress> progressMap)
    {
        var result = new List<MapLevelDto>();
        bool previousLevelCompleted = true; // First level starts accessible

        foreach (var level in levels.OrderBy(l => l.Order))
        {
            var stageDtos = new List<MapStageDto>();
            bool previousStageInLevelCompleted = false;
            bool isFirstStageOfLevel = true;

            var orderedStages = level.Stages.OrderBy(s => s.Order).ToList();

            foreach (var stage in orderedStages)
            {
                bool isCompleted = completedStageIds.Contains(stage.Id);
                string status;

                if (isCompleted)
                {
                    status = "completed";
                    previousStageInLevelCompleted = true;
                }
                else
                {
                    if (isFirstStageOfLevel)
                    {
                        status = previousLevelCompleted ? "available" : "locked";
                    }
                    else
                    {
                        status = previousStageInLevelCompleted ? "available" : "locked";
                    }

                    // A non-completed stage cannot satisfy the requirement for the next stage
                    previousStageInLevelCompleted = false;
                }

                isFirstStageOfLevel = false;

                progressMap.TryGetValue(stage.Id, out var progress);

                stageDtos.Add(new MapStageDto(
                    Id: stage.Id,
                    Order: stage.Order,
                    Type: stage.Type.ToString(),
                    Title: stage.Title,
                    RewardFlames: stage.RewardFlames,
                    Status: status,
                    FlamesEarned: progress?.FlamesEarned ?? 0,
                    Attempts: progress?.Attempts ?? 0
                ));
            }

            // A level is completed if all its stages are completed
            bool isThisLevelCompleted = orderedStages.Count > 0 && 
                                        orderedStages.All(s => completedStageIds.Contains(s.Id));

            // A level is considered locked if its first stage is locked
            bool isLevelLocked = stageDtos.Count == 0 || stageDtos[0].Status == "locked";

            result.Add(new MapLevelDto(
                Id: level.Id,
                Order: level.Order,
                Title: level.Title,
                Theme: level.Theme,
                IconUrl: level.IconUrl,
                IsLocked: isLevelLocked,
                Stages: stageDtos
            ));

            previousLevelCompleted = isThisLevelCompleted;
        }

        return result;
    }
}
