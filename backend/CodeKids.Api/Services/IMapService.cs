using CodeKids.Api.DTOs.Map;
using CodeKids.Api.Models;

namespace CodeKids.Api.Services;

public interface IMapService
{
    Task<MapResponseDto> GetMapForChildAsync(Guid parentId, Guid childId);
    Task<bool> IsStageUnlockedAsync(Guid childId, Guid stageId);
}
