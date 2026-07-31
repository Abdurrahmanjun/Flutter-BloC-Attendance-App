// Drives the app's UI end to end against Prism and captures a screenshot at
// each step, so "it works" can be checked by eye and not just by assertion.
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/walkthrough_test.dart -d <simulator-id> \
//     --dart-define=BASE_URL=http://localhost:4100
//
// Screenshots land in build/screenshots/.
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance/common/location/location_service.dart';
import 'package:attendance/common/network/dev_prefer.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/main.dart';

class _FakeLocationService implements LocationService {
  @override
  Future<Position> currentPosition() async => Position(
        latitude: -6.208763,
        longitude: 106.845599,
        timestamp: DateTime.now(),
        accuracy: 5,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

  @override
  double distanceBetween(double a, double b, double c, double d) =>
      Geolocator.distanceBetween(a, b, c, d);
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.sl.reset();
    await di.init();
    di.sl.unregister<LocationService>();
    di.sl.registerLazySingleton<LocationService>(() => _FakeLocationService());
    DevPrefer.today.value = null;
    DevPrefer.punch.value = null;
  });

  /// Pump until the network round-trip settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('login -> today -> check in -> geofence 422 -> history -> summary',
      (tester) async {
    // Android captures screenshots from a bitmap of the Flutter surface, which
    // must be converted once before the first takeScreenshot. iOS does not need
    // it (and does not offer it), so this is Android-only.
    if (defaultTargetPlatform == TargetPlatform.android) {
      await binding.convertFlutterSurfaceToImage();
    }

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await binding.takeScreenshot('01-login');

    await tester.enterText(find.byType(TextField).at(0), 'budi@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'correct-horse-battery');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk'));
    await settle(tester);

    // `not_checked_in` -> the main button offers Check In.
    expect(find.text('Check in sekarang'), findsOneWidget);
    expect(find.text('Belum absen'), findsOneWidget);
    await binding.takeScreenshot('02-home-not-checked-in');

    // A successful punch: Prism returns 201 with the confirmation message.
    await tester.tap(find.text('Check in sekarang'));
    await settle(tester);
    expect(find.textContaining('Checked in at'), findsOneWidget);
    await binding.takeScreenshot('03-check-in-accepted');
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // The geofence rejection, shown verbatim.
    DevPrefer.punch.value = 'code=422';
    await tester.tap(find.text('Check in sekarang'));
    await settle(tester);
    expect(find.textContaining('from Jakarta HQ'), findsOneWidget);
    await binding.takeScreenshot('04-geofence-422');
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Already checked in today: 409, not a duplicate record.
    DevPrefer.punch.value = 'code=409';
    await tester.tap(find.text('Check in sekarang'));
    await settle(tester);
    expect(find.textContaining('Already checked in'), findsOneWidget);
    await binding.takeScreenshot('05-duplicate-409');
    await tester.pumpAndSettle(const Duration(seconds: 5));
    DevPrefer.punch.value = null;

    // `checked_in` -> the same button now offers Check Out.
    DevPrefer.today.value = 'example=afterLateCheckIn';
    await tester.tap(find.text('Coba lagi').hitTestable().evaluate().isEmpty
        ? find.text('Check in sekarang')
        : find.text('Coba lagi'));
    await settle(tester);
    expect(find.text('Check out'), findsOneWidget);
    expect(find.textContaining('terlambat 3 menit'), findsOneWidget);
    await binding.takeScreenshot('06-home-checked-in');

    // `checked_out` -> the day summary replaces the button entirely.
    DevPrefer.today.value = 'example=afterCheckOut';
    await tester.tap(find.text('Check out'));
    await settle(tester);
    expect(find.text('Hari ini selesai'), findsOneWidget);
    expect(find.text('9j 27m'), findsOneWidget);
    await binding.takeScreenshot('07-home-checked-out');
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // The monthly summary card, further down the home screen.
    await tester.drag(find.text('Pengajuan'), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('Juli 2026'), findsOneWidget);
    await binding.takeScreenshot('08-summary-card');

    // History, on the Absensi tab. Every tab renders its label, so tap that —
    // the icons are no longer unique now that the shell keeps all five pages
    // alive in an IndexedStack.
    await tester.tap(find.text('Absensi'));
    await settle(tester);
    expect(find.text('9 Jul 2026'), findsOneWidget);
    expect(find.text('Terlambat'), findsWidgets);
    expect(find.text('Cuti'), findsOneWidget);
    await binding.takeScreenshot('09-history');

    // The notification feed, from GET /api/notifications.
    await tester.tap(find.text('Notifikasi'));
    await settle(tester);
    expect(find.text('Request - Overtime Approval'), findsOneWidget);
    // The unread count is a bare pill in the redesign, not "2 baru".
    expect(find.text('2'), findsWidgets);
    expect(find.text('Leave approved'), findsOneWidget);
    await binding.takeScreenshot('10-notifications');

    // The debug dev menu that drives Prefer.
    await tester.tap(find.text('Atur'));
    await settle(tester);
    await binding.takeScreenshot('11-dev-menu');

    // The profile, from GET /api/me. It is its own tab in the redesign rather
    // than a route pushed from the home screen's avatar.
    await tester.tap(find.text('Profil'));
    await settle(tester);
    // The home greeting renders the name too, and the shell keeps home alive.
    expect(find.text('Budi Santoso'), findsWidgets);
    expect(find.textContaining('20240117'), findsWidgets);
    // Profil renders the zone as WIB, not the IANA name.
    expect(find.text('09:00 – 18:00 WIB'), findsOneWidget);
    await binding.takeScreenshot('12-profile');
  });
}
