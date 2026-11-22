using System.ComponentModel.DataAnnotations;

namespace CodeKids.Api.Models;

public class Parent
{
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [EmailAddress]
    [MaxLength(256)]
    public string Email { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    [Required]
    public string PinHash { get; set; } = string.Empty;

    [Required]
    [MaxLength(10)]
    public string Language { get; set; } = "en";

    public DateTime CreatedAtUtc { get; set; } = DateTime.UtcNow;

    public ICollection<Child> Children { get; set; } = new List<Child>();
}
