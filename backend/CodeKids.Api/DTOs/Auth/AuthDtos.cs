using System.ComponentModel.DataAnnotations;

namespace CodeKids.Api.DTOs.Auth;

public record RegisterRequestDto(
    [Required][EmailAddress] string Email,
    [Required][MinLength(6)] string Password,
    [Required][RegularExpression(@"^\d{4,6}$", ErrorMessage = "PIN must be 4 to 6 digits.")] string Pin,
    string? Language = "en"
);

public record LoginRequestDto(
    [Required][EmailAddress] string Email,
    [Required] string Password
);

public record VerifyPinRequestDto(
    [Required][RegularExpression(@"^\d{4,6}$", ErrorMessage = "PIN must be 4 to 6 digits.")] string Pin
);

public record VerifyPinResponseDto(
    string Token,
    int ExpiresInSeconds
);

public record ParentDto(
    Guid Id,
    string Email,
    string Language
);

public record AuthResponseDto(
    string Token,
    int ExpiresInSeconds,
    ParentDto Parent
);
