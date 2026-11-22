using CodeKids.Api.DTOs.Auth;

namespace CodeKids.Api.Services;

public interface IAuthService
{
    Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request);
    Task<AuthResponseDto> LoginAsync(LoginRequestDto request);
    Task<VerifyPinResponseDto> VerifyPinAsync(Guid parentId, VerifyPinRequestDto request);
}
