import 'package:flutter/foundation.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/network/problem_details.dart';

/// Translates [ApiException] into child-friendly localized messages.
///
/// Raw server validation details are logged to debug output only.
String localizeApiError(
  AppLocalizations l10n,
  Object error, {
  bool preferServerMessage = false,
}) {
  if (error is! ApiException) {
    debugPrint('Unexpected error: $error');
    return l10n.errorGenericMessage;
  }

  if (error.isOffline) {
    return l10n.errorOfflineMessage;
  }

  final serverMsg = error.serverMessage;
  if (serverMsg != null && serverMsg.isNotEmpty) {
    debugPrint('API error (${error.statusCode}): $serverMsg');
  }

  final hasValidationErrors =
      error.problemDetails?.errors.isNotEmpty ?? false;
  if (hasValidationErrors) {
    debugPrint('API validation errors: ${error.problemDetails!.errors}');
  }

  if (preferServerMessage &&
      !hasValidationErrors &&
      serverMsg != null &&
      serverMsg.isNotEmpty) {
    return serverMsg;
  }

  return switch (error.kind) {
    ApiErrorKind.offline => l10n.errorOfflineMessage,
    ApiErrorKind.badRequest => l10n.errorValidation,
    ApiErrorKind.unauthorized => l10n.errorUnauthorized,
    ApiErrorKind.forbidden => l10n.errorForbidden,
    ApiErrorKind.notFound => l10n.errorNotFound,
    ApiErrorKind.conflict =>
      error.statusCode == 409 &&
              (serverMsg?.toLowerCase().contains('flame') ?? false)
          ? l10n.errorInsufficientFlames
          : (preferServerMessage && serverMsg != null && serverMsg.isNotEmpty
              ? serverMsg
              : l10n.errorGenericMessage),
    ApiErrorKind.server || ApiErrorKind.unknown => l10n.errorGenericMessage,
  };
}
