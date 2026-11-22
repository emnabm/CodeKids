using CodeKids.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CodeKids.Api.Data;

public class CodeKidsDbContext : DbContext
{
    public CodeKidsDbContext(DbContextOptions<CodeKidsDbContext> options) : base(options)
    {
    }

    public DbSet<Parent> Parents => Set<Parent>();
    public DbSet<Child> Children => Set<Child>();
    public DbSet<Level> Levels => Set<Level>();
    public DbSet<Stage> Stages => Set<Stage>();
    public DbSet<Question> Questions => Set<Question>();
    public DbSet<ChildStageProgress> ChildStageProgresses => Set<ChildStageProgress>();
    public DbSet<FlameTransaction> FlameTransactions => Set<FlameTransaction>();
    public DbSet<Badge> Badges => Set<Badge>();
    public DbSet<ChildBadge> ChildBadges => Set<ChildBadge>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Parent
        modelBuilder.Entity<Parent>(entity =>
        {
            entity.HasKey(p => p.Id);
            entity.HasIndex(p => p.Email).IsUnique();
            entity.Property(p => p.Email).IsRequired().HasMaxLength(256);
            entity.Property(p => p.Language).IsRequired().HasMaxLength(10).HasDefaultValue("en");

            entity.HasMany(p => p.Children)
                .WithOne(c => c.Parent)
                .HasForeignKey(c => c.ParentId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Child
        modelBuilder.Entity<Child>(entity =>
        {
            entity.HasKey(c => c.Id);
            entity.HasIndex(c => c.ParentId);

            // Child cascades to its own progress, transactions, and badges
            entity.HasMany(c => c.StageProgresses)
                .WithOne(p => p.Child)
                .HasForeignKey(p => p.ChildId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasMany(c => c.FlameTransactions)
                .WithOne(t => t.Child)
                .HasForeignKey(t => t.ChildId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasMany(c => c.ChildBadges)
                .WithOne(cb => cb.Child)
                .HasForeignKey(cb => cb.ChildId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Level
        modelBuilder.Entity<Level>(entity =>
        {
            entity.HasKey(l => l.Id);
            entity.HasIndex(l => new { l.Language, l.Order });

            entity.HasMany(l => l.Stages)
                .WithOne(s => s.Level)
                .HasForeignKey(s => s.LevelId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Stage
        modelBuilder.Entity<Stage>(entity =>
        {
            entity.HasKey(s => s.Id);
            entity.HasIndex(s => new { s.LevelId, s.Order });

            entity.HasMany(s => s.Questions)
                .WithOne(q => q.Stage)
                .HasForeignKey(q => q.StageId)
                .OnDelete(DeleteBehavior.Cascade);

            // Deleting child must not delete stage; stage -> progress is Restrict
            entity.HasMany(s => s.StageProgresses)
                .WithOne(p => p.Stage)
                .HasForeignKey(p => p.StageId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Question
        modelBuilder.Entity<Question>(entity =>
        {
            entity.HasKey(q => q.Id);
            entity.HasIndex(q => q.StageId);
        });

        // ChildStageProgress
        modelBuilder.Entity<ChildStageProgress>(entity =>
        {
            entity.HasKey(p => p.Id);
            entity.HasIndex(p => new { p.ChildId, p.StageId }).IsUnique();
        });

        // FlameTransaction
        modelBuilder.Entity<FlameTransaction>(entity =>
        {
            entity.HasKey(t => t.Id);
            entity.HasIndex(t => new { t.ChildId, t.CreatedAt });
        });

        // Badge
        modelBuilder.Entity<Badge>(entity =>
        {
            entity.HasKey(b => b.Id);
            entity.HasIndex(b => b.Condition);

            entity.HasMany(b => b.ChildBadges)
                .WithOne(cb => cb.Badge)
                .HasForeignKey(cb => cb.BadgeId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // ChildBadge
        modelBuilder.Entity<ChildBadge>(entity =>
        {
            entity.HasKey(cb => new { cb.ChildId, cb.BadgeId });
        });
    }
}
