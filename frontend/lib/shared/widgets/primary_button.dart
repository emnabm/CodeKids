import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// Vibrant glowing violet gradient button matching the CodeKids mockups.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.backgroundColor,
    this.foregroundColor,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    final enabled = !isLoading && onPressed != null;

    final Gradient? gradient = backgroundColor != null
        ? null
        : LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: enabled
                ? const [Color(0xFF7B5CFF), Color(0xFF5D35EE)]
                : [
                    colors.primary.withValues(alpha: 0.35),
                    colors.primary.withValues(alpha: 0.35),
                  ],
          );

    final buttonContent = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: backgroundColor != null
                ? (enabled
                    ? backgroundColor
                    : backgroundColor!.withValues(alpha: 0.45))
                : null,
            gradient: gradient,
            borderRadius: BorderRadius.circular(28),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: (backgroundColor ?? const Color(0xFF7248FF))
                          .withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Center(
            widthFactor: expand ? null : 1,
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: foregroundColor ?? Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(
                          leadingIcon,
                          size: 20,
                          color: foregroundColor ?? Colors.white,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: foregroundColor ?? Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) ...[
                        const SizedBox(width: 10),
                        Icon(
                          trailingIcon,
                          size: 20,
                          color: foregroundColor ?? Colors.white,
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );

    if (!expand) return buttonContent;
    return SizedBox(width: double.infinity, child: buttonContent);
  }
}
