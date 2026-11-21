using System.ComponentModel.DataAnnotations;

namespace CodeKids.Api.Models;

public class Level
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public int Order { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Theme { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    public string Language { get; set; } = "en";

    [Required]
    [MaxLength(500)]
    public string IconUrl { get; set; } = string.Empty;

    public ICollection<Stage> Stages { get; set; } = new List<Stage>();
}
