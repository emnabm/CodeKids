import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/map/data/models/map_models.dart';

/// Round numbered stage node matching `Map.PNG`.
///
/// Locked nodes show the lock illustration and are never tappable.
class StageNode extends StatelessWidget {
  const StageNode({
    super.key,
    required this.order,
    required this.status,
    required this.title,
    this.onTap,
    this.size = 76,
  });

  final int order;
  final StageStatus status;
  final String title;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    final isLocked = status == StageStatus.locked;
    final isAvailable = status == StageStatus.available;
    final isCompleted = status == StageStatus.completed;

    final Color fillColor = switch (status) {
      StageStatus.locked => const Color(0xFF423D63),
      StageStatus.available => const Color(0xFF6B3DF5),
      StageStatus.completed => const Color(0xFF2882E0),
    };

    final Color borderColor = switch (status) {
      StageStatus.locked => const Color(0xFF625C88),
      StageStatus.available => const Color(0xFFC4B5FD),
      StageStatus.completed => const Color(0xFF7BE0A0),
    };

    final nodeVisual = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: fillColor,
                border: Border.all(
                  color: borderColor,
                  width: isAvailable ? 3.5 : 2.5,
                ),
                boxShadow: isAvailable
                    ? [
                        BoxShadow(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.78),
                          blurRadius: 24,
                          spreadRadius: 5,
                        ),
                      ]
                    : isCompleted
                        ? [
                            BoxShadow(
                              color: const Color(0xFF2882E0)
                                  .withValues(alpha: 0.45),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
              ),
              alignment: Alignment.center,
              child: isLocked
                  ? Image.asset(
                      'assets/images/cadenas.png',
                      width: size * 0.46,
                      height: size * 0.46,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.lock_rounded,
                        color: Color(0xFFCDC9E8),
                        size: 30,
                      ),
                    )
                  : Text(
                      '$order',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            if (isCompleted)
              Positioned(
                right: -4,
                bottom: -4,
                child: Image.asset(
                  'assets/images/validation.png',
                  width: 26,
                  height: 26,
                  errorBuilder: (_, _, _) => Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: colors.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colors.background,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLocked
                  ? colors.mutedText.withValues(alpha: 0.7)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );

    if (isLocked || onTap == null) {
      return Semantics(
        button: false,
        enabled: false,
        label: title,
        child: ExcludeSemantics(child: nodeVisual),
      );
    }

    return Semantics(
      button: true,
      enabled: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: nodeVisual,
          ),
        ),
      ),
    );
  }
}
