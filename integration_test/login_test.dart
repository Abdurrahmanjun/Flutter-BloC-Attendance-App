// End-to-end against the Prism mock. Start it first:
//
//   cd ../attendance-api-contract && npx @stoplight/prism-cli mock openapi.yaml --port 4100
//   flutter test integration_test/login_test.dart -d <simulator-id> \
//     --dart-define=BASE_URL=http://localhost:4100
//
// Nothing is faked: real Dio, real interceptors, real bloc, real HTTP.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.sl.reset();
    await di.init();
  });

  testWidgets('login posts to /api/auth/login and lands on the dashboard',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Splash resolves to login when no token is persisted.
    expect(find.text('Selamat Datang'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'budi@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'correct-horse-battery');
    await tester.tap(find.text('Masuk'));

    // Let the real HTTP round-trip to Prism complete.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Selamat Datang').evaluate().isEmpty) break;
    }
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // We left the login page: the access token from Prism was accepted,
    // decoded by JwtDecoder, and persisted.
    expect(find.text('Selamat Datang'), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('token'), isNotNull);
    // Prism's example refreshToken. Stored, not yet rotated.
    expect(prefs.getString('refresh_token'), '8f14e45fceea167a5a36dedd4bea2543');
  });
}
