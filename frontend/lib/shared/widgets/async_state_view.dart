import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/error_localizer.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/network/problem_details.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/shared/widgets/primary_button.dart';

/// Standard loading / offline / error wrapper with Retry button.
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.isLoading,
    this.error,
    required this.onRetry,
    required this.child,
  });

  final bool isLoading;
  final Object? error;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.ckColors;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.primary),
            const SizedBox(height: 16),
            Text(
              l10n.loading,
              style: TextStyle(color: colors.mutedText, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      final isOffline = error is ApiException && (error as ApiException).isOffline;
      final message = localizeApiError(l10n, error!);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isOffline
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  size: 48,
                  color: isOffline ? colors.flame : colors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  isOffline ? l10n.errorOfflineTitle : l10n.errorGenericTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.mutedText,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: l10n.retry,
                  leadingIcon: Icons.refresh_rounded,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
