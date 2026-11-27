import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/di/providers.dart';
import 'package:frontend/core/network/token_storage.dart';
import 'package:frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Welcome screen renders and switches FR/EN language', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          useMockApiProvider.overrideWithValue(true),
          tokenStorageProvider.overrideWithValue(
            TokenStorage(prefs: prefs, inMemoryOnly: true),
          ),
        ],
        child: const CodeKidsApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    await tester.tap(find.text('FR'));
    await tester.pumpAndSettle();
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);
  });
}
