// /api/me, /api/notifications, /api/announcements, /api/office/locations
// against the Prism mock. See attendance_test.dart for how to run.
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/domain/repositories/profile_repository.dart';
import 'package:attendance/domain/repositories/token_repository.dart';
import 'package:attendance/injection_container.dart' as di;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProfileRepository profile;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.sl.reset();
    await di.init();

    final token = await di.sl<TokenRepository>().setToken(
        username: 'budi@example.com', password: 'correct-horse-battery');
    expect(token.isRight(), isTrue, reason: 'login must succeed');

    profile = di.sl<ProfileRepository>();
  });

  T expectRight<T>(Either<Failure, T> either) => either.fold(
        (failure) => fail('expected success, got '
            '${failure.runtimeType}: ${failure.message}'),
        (value) => value,
      );

  testWidgets('GET /api/me fills the profile', (tester) async {
    final user = expectRight(await profile.me());

    expect(user.id, 42);
    expect(user.nik, '20240117');
    expect(user.name, 'Budi Santoso');
    expect(user.email, 'budi@example.com');
    expect(user.department, 'Engineering');
    expect(user.shift.start, '09:00');
    expect(user.shift.timeZone, 'Asia/Jakarta');
    expect(user.officeId, 1);
    expect(user.joinedAt, DateTime.parse('2024-01-17'));
  });

  testWidgets('GET /api/notifications replaces the hardcoded feed',
      (tester) async {
    final feed = expectRight(await profile.notifications());

    expect(feed.unreadCount, 2);
    expect(feed.notifications.length, 3);

    final first = feed.notifications.first;
    expect(first.kind, NotificationKind.overtimeRequest);
    expect(first.title, 'Request - Overtime Approval');
    expect(first.isUnread, isTrue);

    // The one already-read item in the seed scenario.
    final read = feed.notifications.firstWhere((n) => !n.isUnread);
    expect(read.kind, NotificationKind.leaveApproved);
    expect(read.readAt, isNotNull);
  });

  testWidgets('POST /api/notifications/{id}/read succeeds', (tester) async {
    final result = await profile.markNotificationRead(991);
    expect(result.isRight(), isTrue);
  });

  testWidgets('GET /api/announcements replaces promoImagePaths',
      (tester) async {
    final announcements = expectRight(await profile.announcements());

    expect(announcements, hasLength(1));
    expect(announcements.first.id, 7);
    expect(announcements.first.title, 'Company outing 2026');
    expect(announcements.first.imageUrl, isNotEmpty);
  });

  testWidgets('GET /api/office/locations gives geofence centres',
      (tester) async {
    final offices = expectRight(await profile.offices());

    expect(offices, hasLength(1));
    final hq = offices.first;
    expect(hq.name, 'Jakarta HQ');
    expect(hq.lat, closeTo(-6.208763, 1e-6));
    expect(hq.lng, closeTo(106.845599, 1e-6));
    expect(hq.radiusMeters, 100);
    expect(hq.timeZone, 'Asia/Jakarta');
  });

  testWidgets('unauthenticated /api/me maps to UnauthorizedFailure',
      (tester) async {
    await di.sl<TokenRepository>().logout();

    final failure = (await profile.me()).fold((f) => f, (_) => null);
    expect(failure, isA<UnauthorizedFailure>());
  });
}
