import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/core/l10n/generated/app_localizations.dart';
import 'package:frontend/core/l10n/locale_provider.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CodeKidsApp(),
    ),
  );
}

class CodeKidsApp extends ConsumerWidget {
  const CodeKidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'CodeKids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildDarkTheme(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
