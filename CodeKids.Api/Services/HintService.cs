using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Stages;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using CodeKids.Api.Models.Enums;
using Microsoft.EntityFrameworkCore;

namespace CodeKids.Api.Services;

public class HintService : IHintService
{
    private readonly CodeKidsDbContext _context;
    private readonly IChildService _childService;
    private readonly IMapService _mapService;

    public HintService(CodeKidsDbContext context, IChildService childService, IMapService mapService)
    {
        _context = context;
        _childService = childService;
        _mapService = mapService;
    }

    public async Task<HintResponseDto> PurchaseHintAsync(Guid parentId, Guid stageId, HintRequestDto request)
    {
        // 1. Verify ownership (Hard Rule 1: 403 if not owned, 404 if child not found)
        var child = await _childService.VerifyOwnershipAsync(parentId, request.ChildId);

        // 2. Verify stage exists
        var stageExists = await _context.Stages.AnyAsync(s => s.Id == stageId);
        if (!stageExists)
        {
            throw new NotFoundException($"Stage with ID '{stageId}' was not found.");
        }

        // 3. Verify question exists and belongs to stage
        var question = await _context.Questions
            .FirstOrDefaultAsync(q => q.Id == request.QuestionId && q.StageId == stageId);
        if (question == null)
        {
            throw new NotFoundException($"Question with ID '{request.QuestionId}' was not found in stage '{stageId}'.");
        }

        // 4. Verify stage is unlocked
        var isUnlocked = await _mapService.IsStageUnlockedAsync(child.Id, stageId);
        if (!isUnlocked)
        {
            throw new ValidationException("Cannot request hints for a locked stage.");
        }

        // 5. Transactional hint debit (Hard Rule 3)
        using var transaction = await _context.Database.BeginTransactionAsync();

        var progress = await _context.ChildStageProgresses
            .FirstOrDefaultAsync(p => p.ChildId == child.Id && p.StageId == stageId);

        var hintsUsed = progress?.HintsUsed ?? 0;

        // Hint pricing: 1st = 100, 2nd = 150, 3rd = 200 (+50 each time)
        var cost = CalculateHintCost(hintsUsed);

        if (child.Flames < cost)
        {
            throw new InsufficientFlamesException(cost, child.Flames);
        }

        // Debit child balance
        child.Flames -= cost;

        // Record FlameTransaction
        var flameTx = new FlameTransaction
        {
            ChildId = child.Id,
            Amount = -cost,
            Reason = FlameReason.Hint,
            CreatedAt = DateTime.UtcNow
        };
        _context.FlameTransactions.Add(flameTx);

        // Update or create progress record
        if (progress == null)
        {
            progress = new ChildStageProgress
            {
                ChildId = child.Id,
                StageId = stageId,
                Completed = false,
                HintsUsed = 1,
                Attempts = 0,
                FlamesEarned = 0
            };
            _context.ChildStageProgresses.Add(progress);
        }
        else
        {
            progress.HintsUsed += 1;
        }

        await _context.SaveChangesAsync();
        await transaction.CommitAsync();

        return new HintResponseDto(
            HintText: question.HintText,
            Cost: cost,
            FlamesLeft: child.Flames
        );
    }

    /// <summary>
    /// Computes hint price: 1st = 100, 2nd = 150, 3rd = 200 (+50 each time).
    /// </summary>
    public static int CalculateHintCost(int hintsAlreadyUsed)
    {
        return 100 + (hintsAlreadyUsed * 50);
    }
}
