using CodeKids.Api.DTOs.Stages;

namespace CodeKids.Api.Services;

public interface IHintService
{
    Task<HintResponseDto> PurchaseHintAsync(Guid parentId, Guid stageId, HintRequestDto request);
}
