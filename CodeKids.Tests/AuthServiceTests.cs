using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Auth;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Services;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace CodeKids.Tests;

public class AuthServiceTests
{
    private readonly IConfiguration _configuration;

    public AuthServiceTests()
    {
        var inMemorySettings = new Dictionary<string, string?>
        {
            {"Jwt:Key", "TestSecretKeyThatIsLongEnoughForHmacSha256Testing123456!"},
            {"Jwt:Issuer", "CodeKidsTest"},
            {"Jwt:Audience", "CodeKidsAppTest"},
            {"Jwt:ExpiryHours", "24"},
            {"Jwt:ParentTokenExpiryMinutes", "15"}
        };

        _configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(inMemorySettings)
            .Build();
    }

    private CodeKidsDbContext CreateInMemoryContext()
    {
        var connection = new SqliteConnection("DataSource=:memory:");
        connection.Open();

        var options = new DbContextOptionsBuilder<CodeKidsDbContext>()
            .UseSqlite(connection)
            .Options;

        var context = new CodeKidsDbContext(options);
        context.Database.EnsureCreated();
        return context;
    }

    [Fact]
    public async Task RegisterAsync_ValidRequest_CreatesParentAndReturnsJwt()
    {
        using var context = CreateInMemoryContext();
        var authService = new AuthService(context, _configuration);

        var request = new RegisterRequestDto("newparent@codekids.com", "Secret123!", "5678", "fr");
        var response = await authService.RegisterAsync(request);

        Assert.NotNull(response.Token);
        Assert.NotEmpty(response.Token);
        Assert.Equal("newparent@codekids.com", response.Parent.Email);
        Assert.Equal("fr", response.Parent.Language);

        var saved = await context.Parents.FirstOrDefaultAsync(p => p.Email == "newparent@codekids.com");
        Assert.NotNull(saved);
        Assert.True(BCrypt.Net.BCrypt.Verify("Secret123!", saved.PasswordHash));
        Assert.True(BCrypt.Net.BCrypt.Verify("5678", saved.PinHash));
    }

    [Fact]
    public async Task RegisterAsync_DuplicateEmail_ThrowsConflictException()
    {
        using var context = CreateInMemoryContext();
        var authService = new AuthService(context, _configuration);

        var request1 = new RegisterRequestDto("dup@codekids.com", "Secret123!", "1234", "en");
        await authService.RegisterAsync(request1);

        var request2 = new RegisterRequestDto("dup@codekids.com", "Another123!", "4321", "en");
        await Assert.ThrowsAsync<ConflictException>(() => authService.RegisterAsync(request2));
    }

    [Fact]
    public async Task LoginAsync_ValidCredentials_ReturnsToken()
    {
        using var context = CreateInMemoryContext();
        var authService = new AuthService(context, _configuration);

        await authService.RegisterAsync(new RegisterRequestDto("login@codekids.com", "Pass123!", "1234", "en"));

        var loginResponse = await authService.LoginAsync(new LoginRequestDto("login@codekids.com", "Pass123!"));
        Assert.NotNull(loginResponse.Token);
        Assert.Equal("login@codekids.com", loginResponse.Parent.Email);
    }

    [Fact]
    public async Task LoginAsync_WrongPassword_ThrowsUnauthorizedException()
    {
        using var context = CreateInMemoryContext();
        var authService = new AuthService(context, _configuration);

        await authService.RegisterAsync(new RegisterRequestDto("login2@codekids.com", "Pass123!", "1234", "en"));

        await Assert.ThrowsAsync<UnauthorizedException>(() => 
            authService.LoginAsync(new LoginRequestDto("login2@codekids.com", "WrongPassword!")));
    }

    [Fact]
    public async Task VerifyPinAsync_CorrectPin_ReturnsParentAreaToken()
    {
        using var context = CreateInMemoryContext();
        var authService = new AuthService(context, _configuration);

        var reg = await authService.RegisterAsync(new RegisterRequestDto("pin@codekids.com", "Pass123!", "9876", "en"));

        var pinResponse = await authService.VerifyPinAsync(reg.Parent.Id, new VerifyPinRequestDto("9876"));
        Assert.NotNull(pinResponse.Token);
        Assert.Equal(15 * 60, pinResponse.ExpiresInSeconds);
    }

    [Fact]
    public async Task VerifyPinAsync_WrongPin_ThrowsUnauthorizedException()
    {
        using var context = CreateInMemoryContext();
        var authService = new AuthService(context, _configuration);

        var reg = await authService.RegisterAsync(new RegisterRequestDto("pin2@codekids.com", "Pass123!", "9876", "en"));

        await Assert.ThrowsAsync<UnauthorizedException>(() => 
            authService.VerifyPinAsync(reg.Parent.Id, new VerifyPinRequestDto("0000")));
    }
}
