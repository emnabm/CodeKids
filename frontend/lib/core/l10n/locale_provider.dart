import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists UI locale globally (Welcome / Auth) and per child in
/// [SharedPreferences].
class LocaleNotifier extends Notifier<Locale> {
  static const String _globalLocaleKey = 'codekids_global_locale';
  static const String _childLocalePrefix = 'codekids_child_locale_';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  Locale build() {
    final saved = _prefs.getString(_globalLocaleKey);
    if (saved != null && AppConfig.supportedLanguages.contains(saved)) {
      return Locale(saved);
    }
    final deviceLang = PlatformDispatcher.instance.locale.languageCode;
    if (AppConfig.supportedLanguages.contains(deviceLang)) {
      return Locale(deviceLang);
    }
    return const Locale(AppConfig.defaultLanguage);
  }

  Future<void> setGlobalLocale(String languageCode) async {
    final normalized = _normalize(languageCode);
    await _prefs.setString(_globalLocaleKey, normalized);
    state = Locale(normalized);
  }

  Future<void> setChildLocale(String childId, String languageCode) async {
    final normalized = _normalize(languageCode);
    await _prefs.setString('$_childLocalePrefix$childId', normalized);
    await _prefs.setString(_globalLocaleKey, normalized);
    state = Locale(normalized);
  }

  Future<void> applyChildLocaleIfSaved(String childId) async {
    final saved = _prefs.getString('$_childLocalePrefix$childId');
    if (saved != null && AppConfig.supportedLanguages.contains(saved)) {
      state = Locale(saved);
    }
  }

  String _normalize(String code) {
    final lower = code.trim().toLowerCase();
    return AppConfig.supportedLanguages.contains(lower)
        ? lower
        : AppConfig.defaultLanguage;
  }
}

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);
