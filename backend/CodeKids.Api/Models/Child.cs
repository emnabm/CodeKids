using System.ComponentModel.DataAnnotations;

namespace CodeKids.Api.Models;

public class Child
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid ParentId { get; set; }
    public Parent Parent { get; set; } = null!;

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    public int Age { get; set; }

    [Required]
    [MaxLength(100)]
    public string AvatarId { get; set; } = string.Empty;

    public int Flames { get; set; } = 0;

    public int StreakDays { get; set; } = 0;

    public DateTime? LastActiveDate { get; set; }

    public ICollection<ChildStageProgress> StageProgresses { get; set; } = new List<ChildStageProgress>();
    public ICollection<FlameTransaction> FlameTransactions { get; set; } = new List<FlameTransaction>();
    public ICollection<ChildBadge> ChildBadges { get; set; } = new List<ChildBadge>();
}
