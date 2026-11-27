import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';

/// Shared client-side form validators matching `docs/swagger.json` & rules.
class FormValidators {
  const FormValidators._();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _letterRegex = RegExp(r'[A-Za-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static final RegExp _pinRegex = RegExp(r'^\d{4}$');

  static String? email(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.validationEmailRequired;
    if (!_emailRegex.hasMatch(trimmed)) return l10n.validationEmailInvalid;
    return null;
  }

  /// Minimum 8 characters, at least one letter and one digit.
  static String? password(String? value, AppLocalizations l10n) {
    final raw = value ?? '';
    if (raw.length < 8 ||
        !_letterRegex.hasMatch(raw) ||
        !_digitRegex.hasMatch(raw)) {
      return l10n.validationPasswordRule;
    }
    return null;
  }

  static String? confirmPassword(
    String? value,
    String originalPassword,
    AppLocalizations l10n,
  ) {
    if ((value ?? '') != originalPassword) {
      return l10n.validationPasswordMismatch;
    }
    return null;
  }

  static String? pin(String? value, AppLocalizations l10n) {
    if (value == null || !_pinRegex.hasMatch(value)) {
      return l10n.validationPinLength;
    }
    return null;
  }

  static String? childName(String? value, AppLocalizations l10n) {
    if ((value?.trim() ?? '').isEmpty) {
      return l10n.validationNameRequired;
    }
    return null;
  }

  static String? childAge(int? age, AppLocalizations l10n) {
    if (age == null || age < AppConfig.minChildAge) {
      return l10n.validationAgeMin;
    }
    return null;
  }
}
