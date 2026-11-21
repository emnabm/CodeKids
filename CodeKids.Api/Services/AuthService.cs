using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Auth;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace CodeKids.Api.Services;

public class AuthService : IAuthService
{
    private readonly CodeKidsDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthService(CodeKidsDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var emailExists = await _context.Parents.AnyAsync(p => p.Email == email);
        if (emailExists)
        {
            throw new ConflictException("An account with this email already exists.");
        }

        var language = NormalizeLanguage(request.Language);

        var parent = new Parent
        {
            Email = email,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            PinHash = BCrypt.Net.BCrypt.HashPassword(request.Pin),
            Language = language,
            CreatedAtUtc = DateTime.UtcNow
        };

        _context.Parents.Add(parent);
        await _context.SaveChangesAsync();

        var (token, expiresIn) = GenerateToken(parent, isParentArea: false);

        return new AuthResponseDto(
            Token: token,
            ExpiresInSeconds: expiresIn,
            Parent: new ParentDto(parent.Id, parent.Email, parent.Language)
        );
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request)
    {
        var email = request.Email.Trim().ToLowerInvariant();

        var parent = await _context.Parents.FirstOrDefaultAsync(p => p.Email == email);
        if (parent == null || !BCrypt.Net.BCrypt.Verify(request.Password, parent.PasswordHash))
        {
            throw new UnauthorizedException("Invalid email or password.");
        }

        var (token, expiresIn) = GenerateToken(parent, isParentArea: false);

        return new AuthResponseDto(
            Token: token,
            ExpiresInSeconds: expiresIn,
            Parent: new ParentDto(parent.Id, parent.Email, parent.Language)
        );
    }

    public async Task<VerifyPinResponseDto> VerifyPinAsync(Guid parentId, VerifyPinRequestDto request)
    {
        var parent = await _context.Parents.FirstOrDefaultAsync(p => p.Id == parentId);
        if (parent == null)
        {
            throw new NotFoundException("Parent account not found.");
        }

        if (!BCrypt.Net.BCrypt.Verify(request.Pin, parent.PinHash))
        {
            throw new UnauthorizedException("Incorrect PIN.");
        }

        var (token, expiresIn) = GenerateToken(parent, isParentArea: true);

        return new VerifyPinResponseDto(
            Token: token,
            ExpiresInSeconds: expiresIn
        );
    }

    private (string Token, int ExpiresInSeconds) GenerateToken(Parent parent, bool isParentArea)
    {
        var keyString = _configuration["Jwt:Key"] 
            ?? throw new InvalidOperationException("JWT Secret Key is not configured in settings or environment.");
        var issuer = _configuration["Jwt:Issuer"] ?? "CodeKidsApi";
        var audience = _configuration["Jwt:Audience"] ?? "CodeKidsApp";

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        DateTime expires;
        int expiresInSeconds;

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, parent.Id.ToString()),
            new(ClaimTypes.NameIdentifier, parent.Id.ToString()),
            new(ClaimTypes.Email, parent.Email),
            new("lang", parent.Language)
        };

        if (isParentArea)
        {
            var expiryMinutes = _configuration.GetValue<int?>("Jwt:ParentTokenExpiryMinutes") ?? 15;
            expires = DateTime.UtcNow.AddMinutes(expiryMinutes);
            expiresInSeconds = expiryMinutes * 60;
            claims.Add(new Claim("parent_area", "true"));
        }
        else
        {
            var expiryHours = _configuration.GetValue<int?>("Jwt:ExpiryHours") ?? 24;
            expires = DateTime.UtcNow.AddHours(expiryHours);
            expiresInSeconds = expiryHours * 3600;
        }

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = expires,
            Issuer = issuer,
            Audience = audience,
            SigningCredentials = creds
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);

        return (tokenHandler.WriteToken(token), expiresInSeconds);
    }

    private static string NormalizeLanguage(string? lang)
    {
        if (string.IsNullOrWhiteSpace(lang)) return "en";
        var lower = lang.Trim().ToLowerInvariant();
        return lower switch
        {
            "fr" => "fr",
            "ar" => "ar",
            _ => "en"
        };
    }
}
