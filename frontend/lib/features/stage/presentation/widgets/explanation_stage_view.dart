import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/stage/data/models/stage_models.dart';
import 'package:frontend/shared/widgets/mascot.dart';
import 'package:frontend/shared/widgets/primary_button.dart';
import 'package:google_fonts/google_fonts.dart';

/// Matches `docs/design/StageExplication.png`.
class ExplanationStageView extends StatelessWidget {
  const ExplanationStageView({
    super.key,
    required this.stage,
    required this.isCompleting,
    required this.onGotIt,
  });

  final StageDetailDto stage;
  final bool isCompleting;
  final VoidCallback onGotIt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;
    final content = stage.content;
    final bodyText = content?.text?.trim().isNotEmpty == true
        ? content!.text!
        : (stage.title ?? '');
    final code = content?.codeExample;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Violet title speech pill matching StageExplication.png
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B3DF5), Color(0xFF4F28C8)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              content?.heading?.trim().isNotEmpty == true
                  ? content!.heading!
                  : (stage.title ?? ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Mascot(
            kind: MascotKind.robot,
            size: 130,
          ),
          const SizedBox(height: 14),
          // Light speech bubble matching StageExplication.png
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              bodyText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A1245),
                fontSize: 17,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ),
          if (code != null && code.trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0622),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < code.split('\n').length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${i + 1}',
                              style: GoogleFonts.jetBrainsMono(
                                color: colors.mutedText.withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              code.split('\n')[i],
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF7CE8FF),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          PrimaryButton(
            label: l10n.gotIt,
            isLoading: isCompleting,
            onPressed: onGotIt,
          ),
        ],
      ),
    );
  }
}
