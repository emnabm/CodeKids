import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Displays the child's flame balance inside a compact pill.
class FlameCounter extends StatelessWidget {
  const FlameCounter({
    super.key,
    required this.flames,
    this.compact = false,
  });

  final int flames;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.flame.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: colors.flame,
            size: compact ? 18 : 22,
          ),
          const SizedBox(width: 6),
          Text(
            '$flames',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
