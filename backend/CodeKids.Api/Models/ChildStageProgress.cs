namespace CodeKids.Api.Models;

public class ChildStageProgress
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ChildId { get; set; }
    public Child Child { get; set; } = null!;

    public Guid StageId { get; set; }
    public Stage Stage { get; set; } = null!;

    public bool Completed { get; set; }

    public DateTime? CompletedAt { get; set; }

    public int Attempts { get; set; } = 0;

    public int HintsUsed { get; set; } = 0;

    public int FlamesEarned { get; set; } = 0;
}
