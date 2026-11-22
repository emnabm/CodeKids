using System.ComponentModel.DataAnnotations;

namespace CodeKids.Api.Models;

public class Badge
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Condition { get; set; } = string.Empty;

    [Required]
    [MaxLength(500)]
    public string IconUrl { get; set; } = string.Empty;

    public ICollection<ChildBadge> ChildBadges { get; set; } = new List<ChildBadge>();
}
