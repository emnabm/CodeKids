import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/explanation_panel.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Matches `docs/design/panneauApresErreur.png`.
class WrongAnswerPanel extends StatelessWidget {
  const WrongAnswerPanel({
    super.key,
    required this.correctAnswerDisplay,
    required this.explanationText,
    required this.onContinue,
  });

  final String correctAnswerDisplay;
  final String explanationText;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 26),
                padding: const EdgeInsets.fromLTRB(20, 36, 20, 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFBE185D)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  l10n.wrongAnswerTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Image.asset(
                'assets/images/croix.png',
                width: 56,
                height: 56,
                errorBuilder: (_, _, _) => CircleAvatar(
                  radius: 26,
                  backgroundColor: colors.error,
                  child: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l10n.correctAnswerLabel(correctAnswerDisplay),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.flame,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ExplanationPanel(
            heading: l10n.explanationLabel,
            text: explanationText,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.tryAgainLater,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
