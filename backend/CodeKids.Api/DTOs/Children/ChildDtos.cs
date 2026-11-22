using System.ComponentModel.DataAnnotations;

namespace CodeKids.Api.DTOs.Children;

public record CreateChildRequestDto(
    [Required][MaxLength(100)] string Name,
    [Range(3, 18, ErrorMessage = "Age must be between 3 and 18.")] int Age,
    [Required][MaxLength(100)] string AvatarId
);

public record ChildDto(
    Guid Id,
    string Name,
    int Age,
    string AvatarId,
    int Flames,
    int StreakDays,
    DateTime? LastActiveDate
);
