import 'package:dartz/dartz.dart';

import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/data/models/reference/announcement.dart';
import 'package:attendance/data/models/reference/office.dart';
import 'package:attendance/data/models/user/user.dart';
import 'package:attendance/data/models/leave/leave_balance.dart';
import 'package:attendance/domain/repositories/profile_repository.dart';

class GetMeUseCase {
  final ProfileRepository repository;
  GetMeUseCase(this.repository);

  Future<Either<Failure, User>> call() => repository.me();
}

class GetNotificationsUseCase {
  final ProfileRepository repository;
  GetNotificationsUseCase(this.repository);

  Future<Either<Failure, NotificationFeed>> call({bool unreadOnly = false}) =>
      repository.notifications(unreadOnly: unreadOnly);
}

class MarkNotificationReadUseCase {
  final ProfileRepository repository;
  MarkNotificationReadUseCase(this.repository);

  Future<Either<Failure, Unit>> call(int id) =>
      repository.markNotificationRead(id);
}

class GetAnnouncementsUseCase {
  final ProfileRepository repository;
  GetAnnouncementsUseCase(this.repository);

  Future<Either<Failure, List<Announcement>>> call() =>
      repository.announcements();
}

class GetOfficesUseCase {
  final ProfileRepository repository;
  GetOfficesUseCase(this.repository);

  Future<Either<Failure, List<Office>>> call() => repository.offices();
}

/// `GET /api/leave/balance` — the allowance behind "Sisa cuti" on Profil and
/// "Cuti terpakai" on the monthly report.
class GetLeaveBalanceUseCase {
  final ProfileRepository repository;
  GetLeaveBalanceUseCase(this.repository);

  Future<Either<Failure, List<LeaveBalance>>> call() =>
      repository.leaveBalance();
}
