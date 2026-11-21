using CodeKids.Api.DTOs.Children;
using CodeKids.Api.DTOs.Map;
using CodeKids.Api.DTOs.Rewards;
using CodeKids.Api.Extensions;
using CodeKids.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CodeKids.Api.Controllers;

[ApiController]
[Route("children")]
[Authorize]
[Produces("application/json")]
public class ChildrenController : ControllerBase
{
    private readonly IChildService _childService;
    private readonly IMapService _mapService;
    private readonly IRewardService _rewardService;

    public ChildrenController(
        IChildService childService, 
        IMapService mapService,
        IRewardService rewardService)
    {
        _childService = childService;
        _mapService = mapService;
        _rewardService = rewardService;
    }

    /// <summary>
    /// Get all child profiles belonging to the authenticated parent.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<ChildDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetChildren()
    {
        var parentId = User.GetParentId();
        var children = await _childService.GetChildrenAsync(parentId);
        return Ok(children);
    }

    /// <summary>
    /// Create a new child profile for the authenticated parent.
    /// </summary>
    /// <remarks>
    /// Sample request:
    /// 
    ///     POST /children
    ///     {
    ///        "name": "Alex",
    ///        "age": 10,
    ///        "avatarId": "avatar_robot_blue"
    ///     }
    /// 
    /// </remarks>
    [HttpPost]
    [ProducesResponseType(typeof(ChildDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> CreateChild([FromBody] CreateChildRequestDto request)
    {
        var parentId = User.GetParentId();
        var child = await _childService.CreateChildAsync(parentId, request);
        return CreatedAtAction(nameof(GetChildren), new { id = child.Id }, child);
    }

    /// <summary>
    /// Delete a child profile. Requires ownership by the authenticated parent.
    /// </summary>
    [HttpDelete("{id:guid}")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> DeleteChild(Guid id)
    {
        var parentId = User.GetParentId();
        await _childService.DeleteChildAsync(parentId, id);
        return NoContent();
    }

    /// <summary>
    /// Get game map for a child: levels, stages, computed unlock status, flames, streak.
    /// </summary>
    /// <remarks>
    /// Unlocking is dynamically computed:
    /// - Level 1 Stage 1 is available initially.
    /// - Stage unlocks once the previous stage in the level is completed.
    /// - Level unlocks once the last stage of previous level is completed.
    /// 
    /// Returns texts in parent's language with fallback to English.
    /// </remarks>
    [HttpGet("{id:guid}/map")]
    [ProducesResponseType(typeof(MapResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetMap(Guid id)
    {
        var parentId = User.GetParentId();
        var map = await _mapService.GetMapForChildAsync(parentId, id);
        return Ok(map);
    }

    /// <summary>
    /// Get child reward details: flames, streak, 7-day activity, transaction history, badges.
    /// </summary>
    [HttpGet("{id:guid}/rewards")]
    [ProducesResponseType(typeof(RewardResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetRewards(Guid id)
    {
        var parentId = User.GetParentId();
        var rewards = await _rewardService.GetRewardsAsync(parentId, id);
        return Ok(rewards);
    }

    /// <summary>
    /// Get parent area stats for a child: completed stages, flames per day (last 7 days), progress per level.
    /// Requires parent PIN token (ParentArea authorization policy).
    /// </summary>
    /// <remarks>
    /// Protected endpoint. Must supply JWT Bearer token obtained from POST /auth/verify-pin.
    /// </remarks>
    [Authorize(Policy = "ParentArea")]
    [HttpGet("{id:guid}/stats")]
    [ProducesResponseType(typeof(StatsResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status403Forbidden)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetStats(Guid id)
    {
        var parentId = User.GetParentId();
        var stats = await _rewardService.GetStatsAsync(parentId, id);
        return Ok(stats);
    }
}
