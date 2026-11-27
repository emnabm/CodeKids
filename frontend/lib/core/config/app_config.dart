/// Application-wide configuration derived from `--dart-define` flags.
class AppConfig {
  const AppConfig._();

  /// Base URL for the CodeKids REST API.
  ///
  /// Defaults to `http://10.0.2.2:5000` for the Android emulator.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  /// When `true`, uses local mock repositories instead of live HTTP calls.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'fr'];
  static const int minChildAge = 10;
  static const int pinLength = 4;
  static const int maxPinAttempts = 5;
  static const int baseHintPrice = 100;
  static const int hintPriceStep = 50;
}
