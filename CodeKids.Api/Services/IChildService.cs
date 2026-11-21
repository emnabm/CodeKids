using CodeKids.Api.DTOs.Children;
using CodeKids.Api.Models;

namespace CodeKids.Api.Services;

public interface IChildService
{
    Task<IEnumerable<ChildDto>> GetChildrenAsync(Guid parentId);
    Task<ChildDto> CreateChildAsync(Guid parentId, CreateChildRequestDto request);
    Task DeleteChildAsync(Guid parentId, Guid childId);
    Task<Child> VerifyOwnershipAsync(Guid parentId, Guid childId);
}
