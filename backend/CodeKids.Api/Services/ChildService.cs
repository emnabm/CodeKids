using CodeKids.Api.Data;
using CodeKids.Api.DTOs.Children;
using CodeKids.Api.Exceptions;
using CodeKids.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CodeKids.Api.Services;

public class ChildService : IChildService
{
    private readonly CodeKidsDbContext _context;

    public ChildService(CodeKidsDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<ChildDto>> GetChildrenAsync(Guid parentId)
    {
        var children = await _context.Children
            .AsNoTracking()
            .Where(c => c.ParentId == parentId)
            .OrderBy(c => c.Name)
            .Select(c => new ChildDto(
                c.Id,
                c.Name,
                c.Age,
                c.AvatarId,
                c.Flames,
                c.StreakDays,
                c.LastActiveDate
            ))
            .ToListAsync();

        return children;
    }

    public async Task<ChildDto> CreateChildAsync(Guid parentId, CreateChildRequestDto request)
    {
        var parentExists = await _context.Parents.AnyAsync(p => p.Id == parentId);
        if (!parentExists)
        {
            throw new NotFoundException("Parent account not found.");
        }

        var child = new Child
        {
            ParentId = parentId,
            Name = request.Name.Trim(),
            Age = request.Age,
            AvatarId = request.AvatarId.Trim(),
            Flames = 0,
            StreakDays = 0,
            LastActiveDate = null
        };

        _context.Children.Add(child);
        await _context.SaveChangesAsync();

        return new ChildDto(
            child.Id,
            child.Name,
            child.Age,
            child.AvatarId,
            child.Flames,
            child.StreakDays,
            child.LastActiveDate
        );
    }

    public async Task DeleteChildAsync(Guid parentId, Guid childId)
    {
        var child = await VerifyOwnershipAsync(parentId, childId);

        _context.Children.Remove(child);
        await _context.SaveChangesAsync();
    }

    public async Task<Child> VerifyOwnershipAsync(Guid parentId, Guid childId)
    {
        var child = await _context.Children.FirstOrDefaultAsync(c => c.Id == childId);
        if (child == null)
        {
            throw new NotFoundException($"Child with ID '{childId}' was not found.");
        }

        if (child.ParentId != parentId)
        {
            throw new ForbiddenException("You do not have access to this child profile.");
        }

        return child;
    }
}
