using System.ComponentModel.DataAnnotations;
using CodeKids.Api.Models.Enums;

namespace CodeKids.Api.Models;

public class Question
{
    public Guid Id { get; set; } = Guid.NewGuid();

    public Guid StageId { get; set; }
    public Stage Stage { get; set; } = null!;

    public QuestionType Type { get; set; }

    [Required]
    public string Text { get; set; } = string.Empty;

    [Required]
    public string OptionsJson { get; set; } = "[]";

    [Required]
    public string AnswerJson { get; set; } = "{}";

    [Required]
    public string HintText { get; set; } = string.Empty;

    [Required]
    public string ExplanationText { get; set; } = string.Empty;
}
