import 'package:flutter/material.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/theme/app_theme.dart';

/// 4-digit masked PIN keypad matching the `Saisissez votre PIN` mockup.
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.pinLength,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.maxLength = AppConfig.pinLength,
    this.enabled = true,
    this.errorText,
  });

  final int pinLength;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final int maxLength;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLength, (index) {
            final filled = index < pinLength;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? Colors.white : const Color(0xFF332B66),
                border: errorText != null
                    ? Border.all(color: colors.error, width: 1.5)
                    : null,
              ),
            );
          }),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Text(
            errorText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.error,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 276),
          child: Column(
            children: [
              _buildRow(context, ['1', '2', '3']),
              const SizedBox(height: 12),
              _buildRow(context, ['4', '5', '6']),
              const SizedBox(height: 12),
              _buildRow(context, ['7', '8', '9']),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _KeypadDotPlaceholder(),
                  _KeypadButton(
                    label: '0',
                    enabled: enabled,
                    onTap: () => onDigitPressed('0'),
                  ),
                  _KeypadButton(
                    icon: Icons.backspace_outlined,
                    semanticLabel: 'Delete',
                    enabled: enabled && pinLength > 0,
                    onTap: onDeletePressed,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: digits
          .map(
            (digit) => _KeypadButton(
              label: digit,
              enabled: enabled,
              onTap: () => onDigitPressed(digit),
            ),
          )
          .toList(),
    );
  }
}

class _KeypadDotPlaceholder extends StatelessWidget {
  const _KeypadDotPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 56,
      alignment: Alignment.center,
      child: Text(
        '•',
        style: TextStyle(
          fontSize: 22,
          color: context.ckColors.mutedText.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    this.label,
    this.icon,
    this.semanticLabel,
    required this.enabled,
    required this.onTap,
  });

  final String? label;
  final IconData? icon;
  final String? semanticLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: Material(
        color: const Color(0xFF171142),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 78,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colors.border.withValues(alpha: 0.65),
              ),
            ),
            alignment: Alignment.center,
            child: label != null
                ? Text(
                    label!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: enabled ? Colors.white : colors.mutedText,
                    ),
                  )
                : Icon(
                    icon,
                    size: 22,
                    color: enabled ? Colors.white : colors.mutedText,
                  ),
          ),
        ),
      ),
    );
  }
}
