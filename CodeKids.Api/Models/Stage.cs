using System.ComponentModel.DataAnnotations;
using CodeKids.Api.Models.Enums;

namespace CodeKids.Api.Models;

public class Stage
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid LevelId { get; set; }
    public Level Level { get; set; } = null!;

    public int Order { get; set; }

    public StageType Type { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    public int RewardFlames { get; set; }

    [Required]
    public string ContentJson { get; set; } = "{}";

    public ICollection<Question> Questions { get; set; } = new List<Question>();
    public ICollection<ChildStageProgress> StageProgresses { get; set; } = new List<ChildStageProgress>();
}
