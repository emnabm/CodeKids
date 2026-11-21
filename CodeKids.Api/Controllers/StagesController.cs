using CodeKids.Api.DTOs.Stages;
using CodeKids.Api.Extensions;
using CodeKids.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CodeKids.Api.Controllers;

[ApiController]
[Route("stages")]
[Authorize]
[Produces("application/json")]
public class StagesController : ControllerBase
{
    private readonly IStageService _stageService;
    private readonly IHintService _hintService;

    public StagesController(IStageService stageService, IHintService hintService)
    {
        _stageService = stageService;
        _hintService = hintService;
    }

    /// <summary>
    /// Get stage content, questions, hint texts, and explanation texts.
    /// </summary>
    /// <remarks>
    /// Rejects locked stages.
    /// Returns options and answer objects formatted cleanly according to the question type schema.
    /// The Flutter client checks answers locally while server retains anti-cheat authority over rewards and progress.
    /// </remarks>
    /// <param name="id">The Stage GUID</param>
    /// <param name="childId">The Child GUID (must belong to authenticated parent)</param>
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(StageDetailDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetStage(Guid id, [FromQuery] Guid childId)
    {
        var parentId = User.GetParentId();
        var stage = await _stageService.GetStageContentAsync(parentId, id, childId);
        return Ok(stage);
    }

    /// <summary>
    /// Purchase a hint for a question within a stage.
    /// </summary>
    /// <remarks>
    /// Hints cost flames and escalate in price within the same stage for the child:
    /// - 1st hint: 100 flames
    /// - 2nd hint: 150 flames
    /// - 3rd hint: 200 flames (+50 flames each time)
    /// 
    /// If the child does not have sufficient flames, returns 409 Conflict with ProblemDetails.
    /// 
    /// Sample request:
    /// 
    ///     POST /stages/{stageId}/hint
    ///     {
    ///        "childId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    ///        "questionId": "7cb85f64-5717-4562-b3fc-2c963f66afa1"
    ///     }
    /// 
    /// </remarks>
    [HttpPost("{id:guid}/hint")]
    [ProducesResponseType(typeof(HintResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
    public async Task<IActionResult> PurchaseHint(Guid id, [FromBody] HintRequestDto request)
    {
        var parentId = User.GetParentId();
        var hint = await _hintService.PurchaseHintAsync(parentId, id, request);
        return Ok(hint);
    }

    /// <summary>
    /// Mark a stage as completed.
    /// </summary>
    /// <remarks>
    /// Idempotent (calling twice never doubles flames).
    /// Executed within a single database transaction (progress, flames, transactions, streak, badges).
    /// 
    /// Rewards:
    /// - Explanation: 10 flames
    /// - Quiz: 25 flames
    /// - Final: 60 flames
    /// - Streak bonus: +5 flames per consecutive day (capped at +50)
    /// 
    /// Replaying a completed stage is allowed for practice but grants 0 flames.
    /// 
    /// Sample request:
    /// 
    ///     POST /stages/{stageId}/complete
    ///     {
    ///        "childId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    ///        "hintsUsed": 1,
    ///        "attempts": 2
    ///     }
    /// 
    /// </remarks>
    [HttpPost("{id:guid}/complete")]
    [ProducesResponseType(typeof(CompleteStageResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> CompleteStage(Guid id, [FromBody] CompleteStageRequestDto request)
    {
        var parentId = User.GetParentId();
        var response = await _stageService.CompleteStageAsync(parentId, id, request);
        return Ok(response);
    }
}
