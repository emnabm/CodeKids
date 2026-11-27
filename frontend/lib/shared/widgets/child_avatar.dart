import 'package:flutter/material.dart';
import 'package:frontend/core/avatars/avatar_catalog.dart';

/// Glowing circular child avatar matching `creerProfileEnfant.png` and `Profile.png`.
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.borderColor,
    this.glow = false,
  });

  final String? avatarId;
  final double size;
  final Color? borderColor;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final option = AvatarCatalog.resolve(avatarId);
    final ringColor = borderColor ?? const Color(0xFF7B5CFF);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            option.backgroundColor.withValues(alpha: 0.85),
            const Color(0xFF171142),
          ],
        ),
        border: Border.all(
          color: ringColor,
          width: size >= 80 ? 3 : 2,
        ),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: ringColor.withValues(alpha: 0.55),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: Image.asset(
            option.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              option.fallbackIcon,
              size: size * 0.56,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
