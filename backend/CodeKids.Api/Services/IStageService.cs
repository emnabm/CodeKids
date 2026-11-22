using CodeKids.Api.DTOs.Stages;

namespace CodeKids.Api.Services;

public interface IStageService
{
    Task<StageDetailDto> GetStageContentAsync(Guid parentId, Guid stageId, Guid childId);
    Task<CompleteStageResponseDto> CompleteStageAsync(Guid parentId, Guid stageId, CompleteStageRequestDto request);
}
