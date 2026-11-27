import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays an explanation text card with an optional Python code snippet.
class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({
    super.key,
    required this.text,
    this.heading,
    this.codeSnippet,
    this.highlightCorrectAnswer,
    this.lightBubble = false,
  });

  final String text;
  final String? heading;
  final String? codeSnippet;
  final String? highlightCorrectAnswer;
  final bool lightBubble;

  @override
  Widget build(BuildContext context) {
    final colors = context.ckColors;
    final cardColor = lightBubble ? const Color(0xFFEDE9FE) : colors.card;
    final textColor = lightBubble ? const Color(0xFF1A1245) : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: lightBubble ? Colors.white : colors.border,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null && heading!.trim().isNotEmpty) ...[
            Text(
              heading!,
              style: TextStyle(
                color: lightBubble ? colors.primary : colors.mutedText,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (highlightCorrectAnswer != null &&
              highlightCorrectAnswer!.trim().isNotEmpty) ...[
            Text(
              highlightCorrectAnswer!,
              style: TextStyle(
                color: colors.flame,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              height: 1.45,
            ),
          ),
          if (codeSnippet != null && codeSnippet!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0622),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Text(
                codeSnippet!,
                style: GoogleFonts.jetBrainsMono(
                  color: const Color(0xFF7CE8FF),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
