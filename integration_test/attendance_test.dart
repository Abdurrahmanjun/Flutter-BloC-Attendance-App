// Drives the whole attendance day against the Prism mock. Start it first:
//
//   cd ../attendance-api-contract && npx @stoplight/prism-cli mock openapi.yaml --port 4100
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/attendance_test.dart -d <simulator-id> \
//     --dart-define=BASE_URL=http://localhost:4100
//
// Real Dio, real interceptors, real HTTP. Only two things are substituted:
//   * the GPS fix — a simulator has no meaningful one, and the punch bodies
//     still go over the wire and are validated by Prism against the schema;
//   * DevPrefer, standing in for the debug dev menu, because Prism is stateless
//     and cannot be walked through the day any other way.
//
// Errors are asserted on *status-derived Failure types*, never on message text:
// Prism replays the spec's 422 example for its own schema-validation failures,
// so a missing `lat` comes back wearing the geofence message.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance/common/error/failures.dart';
import 'package:attendance/common/location/location_service.dart';
import 'package:attendance/common/network/dev_prefer.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';
import 'package:attendance/domain/repositories/attendance_repository.dart';
import 'package:attendance/domain/repositories/token_repository.dart';
import 'package:attendance/injection_container.dart' as di;

/// Jakarta HQ's centre, per `GET /api/office/locations`.
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
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AttendanceRepository attendance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.sl.reset();
    await di.init();
    di.sl.unregister<LocationService>();
    di.sl.registerLazySingleton<LocationService>(() => _FakeLocationService());

    DevPrefer.today.value = null;
    DevPrefer.punch.value = null;

    // Real login: the access token is what the auth interceptor then attaches.
    // Prism 401s any request without an Authorization header, so everything
    // below depends on this having worked.
    final token = await di.sl<TokenRepository>()
        .setToken(username: 'budi@example.com', password: 'correct-horse-battery');
    expect(token.isRight(), isTrue, reason: 'login must succeed');

    attendance = di.sl<AttendanceRepository>();
  });

  T expectRight<T>(Either<Failure, T> either) => either.fold(
        (failure) => fail('expected success, got ${failure.runtimeType}: ${failure.message}'),
        (value) => value,
      );

  Failure expectLeft<T>(Either<Failure, T> either) => either.fold(
        (failure) => failure,
        (value) => fail('expected failure, got $value'),
      );

  testWidgets('today: 08:55 before check-in', (tester) async {
    final today = expectRight(await attendance.today());
    expect(today.status, TodayStatus.notCheckedIn);
    expect(today.canCheckIn, isTrue);
    expect(today.workedMinutes, 0);
    expect(today.shift.timeZone, 'Asia/Jakarta');
  });

  testWidgets('today: after a late check-in', (tester) async {
    DevPrefer.today.value = 'example=afterLateCheckIn';
    final today = expectRight(await attendance.today());

    expect(today.status, TodayStatus.checkedIn);
    expect(today.canCheckOut, isTrue);
    expect(today.isLate, isTrue);
    expect(today.lateByMinutes, 3);
    expect(today.checkInAt, isNotNull);
  });

  testWidgets('today: after check-out shows the day summary', (tester) async {
    DevPrefer.today.value = 'example=afterCheckOut';
    final today = expectRight(await attendance.today());

    expect(today.status, TodayStatus.checkedOut);
    expect(today.isDone, isTrue);
    expect(today.workedMinutes, 567); // 9h 27m
    expect(today.checkOutAt, isNotNull);
  });

  testWidgets('check-in inside the geofence is accepted, and carries the message', (tester) async {
    final result = expectRight(await attendance.checkIn());

    expect(result.entry.isLate, isTrue);
    expect(result.entry.lateByMinutes, 3);
    // The confirmation text lives only in the envelope's `message`.
    expect(result.message, contains('Checked in'));
  });

  testWidgets('check-in twice in a day is a 409 and is not retried', (tester) async {
    DevPrefer.punch.value = 'code=409';
    final failure = expectLeft(await attendance.checkIn());

    expect(failure, isA<ConflictFailure>());
    expect(failure.message, isNotEmpty);
  });

  testWidgets('check-in outside the geofence is a 422 carrying the distance', (tester) async {
    DevPrefer.punch.value = 'code=422';
    final failure = expectLeft(await attendance.checkIn());

    expect(failure, isA<ValidationFailure>());
    // Asserting only that the server's text is surfaced, not what it says.
    expect(failure.message, isNotEmpty);
  });

  testWidgets('check-out returns worked minutes', (tester) async {
    final result = expectRight(await attendance.checkOut());

    expect(result.entry.checkOutAt, isNotNull);
    expect(result.entry.workedMinutes, 567);
    expect(result.message, contains('Checked out'));
  });

  testWidgets('history: a page of entries, newest first', (tester) async {
    final page = expectRight(await attendance.history(page: 1, perPage: 20));

    expect(page.page, 1);
    expect(page.totalEntries, 22);
    expect(page.totalPages, 2);
    expect(page.hasMore, isTrue);
    expect(page.entries, isNotEmpty);

    // The seeded day, plus the non-punch statuses the list has to render.
    expect(page.entries.first.date.day, 9);
    expect(page.entries.first.isLate, isTrue);
    expect(page.entries.any((e) => e.status == EntryStatus.leave), isTrue);
    expect(page.entries.any((e) => e.status == EntryStatus.absent), isTrue);
    // absent/leave days carry no punches and no office.
    final leave = page.entries.firstWhere((e) => e.status == EntryStatus.leave);
    expect(leave.checkInAt, isNull);
    expect(leave.officeId, isNull);
  });

  testWidgets('summary: late is a subset of present', (tester) async {
    final summary = expectRight(await attendance.summary('2026-07'));

    expect(summary.month, '2026-07');
    expect(summary.workingDays, 22);
    expect(summary.present, 18);
    expect(summary.late, 2);
    expect(summary.absent, 1);
    expect(summary.leave, 1);
    expect(summary.averageCheckInTime, '08:58');

    // The rule the card depends on: late days are present days.
    expect(summary.onTime, 16);
    expect(summary.late, lessThanOrEqualTo(summary.present));
  });

  testWidgets('an unauthenticated request maps to UnauthorizedFailure', (tester) async {
    // Drop the token, so the auth interceptor sends no Authorization header and
    // Prism rejects the request with a 401.
    await di.sl<TokenRepository>().logout();

    final failure = expectLeft(await attendance.today());
    expect(failure, isA<UnauthorizedFailure>());
  });
}
