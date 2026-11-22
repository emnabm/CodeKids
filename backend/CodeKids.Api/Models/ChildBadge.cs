namespace CodeKids.Api.Models;

public class ChildBadge
{
    public Guid ChildId { get; set; }
    public Child Child { get; set; } = null!;

    public Guid BadgeId { get; set; }
    public Badge Badge { get; set; } = null!;

    public DateTime EarnedAt { get; set; } = DateTime.UtcNow;
}
