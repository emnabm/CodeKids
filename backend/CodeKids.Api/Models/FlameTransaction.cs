using CodeKids.Api.Models.Enums;

namespace CodeKids.Api.Models;

public class FlameTransaction
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ChildId { get; set; }
    public Child Child { get; set; } = null!;

    public int Amount { get; set; }

    public FlameReason Reason { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
