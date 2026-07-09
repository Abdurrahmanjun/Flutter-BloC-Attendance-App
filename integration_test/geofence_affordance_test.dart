// The local geofence affordance: with a fix far from every office returned by
// GET /api/office/locations, the check-in button greys out and explains why.
//
// It is only an affordance. If no fix is available the button must stay
// enabled, because the server re-validates and is the authority.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance/common/location/location_service.dart';
import 'package:attendance/common/network/dev_prefer.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/main.dart';

class _FixedLocationService implements LocationService {
  final double lat;
  final double lng;

  /// When true, behave like a device that cannot get a fix.
  final bool fails;

  const _FixedLocationService({
    this.lat = 0,
    this.lng = 0,
    this.fails = false,
  });

  @override
  Future<Position> currentPosition() async {
    if (fails) throw const LocationException('Layanan lokasi mati.');
    return Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  @override
  double distanceBetween(double a, double b, double c, double d) =>
      Geolocator.distanceBetween(a, b, c, d);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> boot(WidgetTester tester, LocationService location) async {
    SharedPreferences.setMockInitialValues({});
    await di.sl.reset();
    await di.init();
    di.sl.unregister<LocationService>();
    di.sl.registerLazySingleton<LocationService>(() => location);
    DevPrefer.today.value = null;
    DevPrefer.punch.value = null;

    // No token is seeded: splash must land on login, and we sign in through
    // the UI exactly as a user would.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'budi@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'correct-horse-battery');
    await tester.tap(find.text('LOGIN'));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('far from Jakarta HQ: button disabled, distance explained',
      (tester) async {
    // Monas, ~2.9km north of the Jl. Sudirman office (radius 100m).
    await boot(tester, const _FixedLocationService(lat: -6.1754, lng: 106.8272));

    expect(find.text('CHECK IN'), findsOneWidget);
    expect(find.textContaining('dari Jakarta HQ'), findsOneWidget);
    expect(find.textContaining('Mendekat ke kantor'), findsOneWidget);

    // Tapping does nothing: no punch is attempted, so no snackbar appears.
    await tester.tap(find.text('CHECK IN'));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('Checked in at'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('inside the fence: button enabled, no distance warning',
      (tester) async {
    // The office centre itself.
    await boot(
        tester, const _FixedLocationService(lat: -6.208763, lng: 106.845599));

    expect(find.text('CHECK IN'), findsOneWidget);
    expect(find.textContaining('Mendekat ke kantor'), findsNothing);

    await tester.tap(find.text('CHECK IN'));
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.textContaining('Checked in at'), findsOneWidget);
  });

  testWidgets('no fix: button stays enabled, server decides', (tester) async {
    await boot(tester, const _FixedLocationService(fails: true));

    expect(find.text('CHECK IN'), findsOneWidget);
    expect(find.textContaining('Mendekat ke kantor'), findsNothing);
  });
}
