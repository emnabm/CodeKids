import 'package:flutter/material.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/l10n/error_localizer.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';
import 'package:frontend/shared/widgets/flame_counter.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Matches `docs/design/UtiliserIndice.png`.
///
/// Keeps hint hidden until `POST /stages/{id}/hint` succeeds.
class HintModalDialog extends StatefulWidget {
  const HintModalDialog({
    super.key,
    required this.initialFlames,
    required this.estimatedPrice,
    this.alreadyUnlockedHint,
    required this.onPurchaseHint,
  });

  final int initialFlames;
  final int estimatedPrice;
  final String? alreadyUnlockedHint;
  final Future<HintResponseDto> Function() onPurchaseHint;

  @override
  State<HintModalDialog> createState() => _HintModalDialogState();
}

class _HintModalDialogState extends State<HintModalDialog> {
  late int _flames;
  String? _revealedHint;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _flames = widget.initialFlames;
    _revealedHint = widget.alreadyUnlockedHint;
  }

  Future<void> _unlock() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.onPurchaseHint();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _flames = response.flamesLeft;
        _revealedHint = response.hintText ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _errorMessage = localizeApiError(l10n, e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final isUnlocked = _revealedHint != null;
    final clearlyInsufficient = _flames < AppConfig.baseHintPrice;

    return Dialog(
      backgroundColor: const Color(0xFF140D3A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: colors.border, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.hintTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                FlameCounter(flames: _flames, compact: true),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    colors.flame.withValues(alpha: 0.45),
                    colors.flame.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Icon(
                Icons.lightbulb_rounded,
                size: 56,
                color: colors.flame,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border),
              ),
              child: isUnlocked
                  ? Text(
                      _revealedHint!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          l10n.hintEstimatedCost(widget.estimatedPrice),
                          style: TextStyle(
                            color: colors.flame,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.hintHiddenPlaceholder,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.mutedText,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.error,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 20),
            if (isUnlocked)
              PrimaryButton(
                label: l10n.close,
                onPressed: () => Navigator.of(context).pop(),
              )
            else ...[
              PrimaryButton(
                label: l10n.unlockHintButton,
                leadingIcon: Icons.lightbulb_outline_rounded,
                isLoading: _isLoading,
                onPressed: clearlyInsufficient ? null : _unlock,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                child: Text(
                  l10n.close,
                  style: TextStyle(color: colors.mutedText),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
