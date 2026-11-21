using CodeKids.Api.DTOs.Rewards;

namespace CodeKids.Api.Services;

public interface IRewardService
{
    Task<RewardResponseDto> GetRewardsAsync(Guid parentId, Guid childId);
    Task<StatsResponseDto> GetStatsAsync(Guid parentId, Guid childId);
}
