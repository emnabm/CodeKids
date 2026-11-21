using CodeKids.Api.DTOs.Auth;
using CodeKids.Api.Extensions;
using CodeKids.Api.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CodeKids.Api.Controllers;

[ApiController]
[Route("auth")]
[Produces("application/json")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// Register a new parent account.
    /// </summary>
    /// <remarks>
    /// Sample request:
    /// 
    ///     POST /auth/register
    ///     {
    ///        "email": "parent@example.com",
    ///        "password": "Password123!",
    ///        "pin": "1234",
    ///        "language": "en"
    ///     }
    /// 
    /// </remarks>
    [HttpPost("register")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status409Conflict)]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto request)
    {
        var response = await _authService.RegisterAsync(request);
        return StatusCode(StatusCodes.Status201Created, response);
    }

    /// <summary>
    /// Login with existing parent email and password.
    /// </summary>
    /// <remarks>
    /// Sample request:
    /// 
    ///     POST /auth/login
    ///     {
    ///        "email": "demo@codekids.com",
    ///        "password": "Password123!"
    ///     }
    /// 
    /// </remarks>
    [HttpPost("login")]
    [ProducesResponseType(typeof(AuthResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        var response = await _authService.LoginAsync(request);
        return Ok(response);
    }

    /// <summary>
    /// Verify parent PIN to obtain a short-lived parent-area token.
    /// </summary>
    /// <remarks>
    /// Requires Bearer authentication. Returns a short-lived (15 min) JWT with claim `parent_area: "true"` needed for `/children/{id}/stats`.
    /// 
    /// Sample request:
    /// 
    ///     POST /auth/verify-pin
    ///     {
    ///        "pin": "1234"
    ///     }
    /// 
    /// </remarks>
    [Authorize]
    [HttpPost("verify-pin")]
    [ProducesResponseType(typeof(VerifyPinResponseDto), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(typeof(ProblemDetails), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> VerifyPin([FromBody] VerifyPinRequestDto request)
    {
        var parentId = User.GetParentId();
        var response = await _authService.VerifyPinAsync(parentId, request);
        return Ok(response);
    }
}
