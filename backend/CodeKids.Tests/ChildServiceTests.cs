using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Auth;
using CodeKids.Api.DTOs.Children;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Services;
using Microsoft.Data.Sqlite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Xunit;

namespace CodeKids.Tests;

public class ChildServiceTests
{
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
    public async Task CreateChildAsync_ValidData_CreatesChildProfile()
    {
        using var context = CreateInMemoryContext();
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            {"Jwt:Key", "TestSecretKeyThatIsLongEnoughForHmacSha256Testing123456!"}
        }).Build();

        var authService = new AuthService(context, config);
        var reg = await authService.RegisterAsync(new RegisterRequestDto("p1@test.com", "Pass123!", "1234", "en"));

        var childService = new ChildService(context);
        var child = await childService.CreateChildAsync(reg.Parent.Id, new CreateChildRequestDto("Emma", 11, "avatar_girl_coder"));

        Assert.NotNull(child);
        Assert.Equal("Emma", child.Name);
        Assert.Equal(11, child.Age);
        Assert.Equal("avatar_girl_coder", child.AvatarId);
        Assert.Equal(0, child.Flames);
        Assert.Equal(0, child.StreakDays);
        Assert.Null(child.LastActiveDate);

        var list = (await childService.GetChildrenAsync(reg.Parent.Id)).ToList();
        Assert.Single(list);
        Assert.Equal("Emma", list[0].Name);
    }

    [Fact]
    public async Task VerifyOwnershipAsync_OtherParentChild_ThrowsForbiddenException()
    {
        using var context = CreateInMemoryContext();
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            {"Jwt:Key", "TestSecretKeyThatIsLongEnoughForHmacSha256Testing123456!"}
        }).Build();

        var authService = new AuthService(context, config);
        var parent1 = await authService.RegisterAsync(new RegisterRequestDto("p1@test.com", "Pass123!", "1234", "en"));
        var parent2 = await authService.RegisterAsync(new RegisterRequestDto("p2@test.com", "Pass123!", "1234", "en"));

        var childService = new ChildService(context);
        var childOfParent1 = await childService.CreateChildAsync(parent1.Parent.Id, new CreateChildRequestDto("Sam", 10, "avatar_fox"));

        // Parent 2 tries to access or delete Parent 1's child -> MUST throw ForbiddenException (403)
        await Assert.ThrowsAsync<ForbiddenException>(() => 
            childService.VerifyOwnershipAsync(parent2.Parent.Id, childOfParent1.Id));

        await Assert.ThrowsAsync<ForbiddenException>(() => 
            childService.DeleteChildAsync(parent2.Parent.Id, childOfParent1.Id));
    }

    [Fact]
    public async Task VerifyOwnershipAsync_NonExistentChild_ThrowsNotFoundException()
    {
        using var context = CreateInMemoryContext();
        var childService = new ChildService(context);

        await Assert.ThrowsAsync<NotFoundException>(() => 
            childService.VerifyOwnershipAsync(Guid.NewGuid(), Guid.NewGuid()));
    }

    [Fact]
    public async Task DeleteChildAsync_OwnerParent_DeletesSuccessfully()
    {
        using var context = CreateInMemoryContext();
        var config = new ConfigurationBuilder().AddInMemoryCollection(new Dictionary<string, string?>
        {
            {"Jwt:Key", "TestSecretKeyThatIsLongEnoughForHmacSha256Testing123456!"}
        }).Build();

        var authService = new AuthService(context, config);
        var parent = await authService.RegisterAsync(new RegisterRequestDto("p1@test.com", "Pass123!", "1234", "en"));

        var childService = new ChildService(context);
        var child = await childService.CreateChildAsync(parent.Parent.Id, new CreateChildRequestDto("Leo", 12, "avatar_cat"));

        await childService.DeleteChildAsync(parent.Parent.Id, child.Id);

        var list = await childService.GetChildrenAsync(parent.Parent.Id);
        Assert.Empty(list);
    }
}
