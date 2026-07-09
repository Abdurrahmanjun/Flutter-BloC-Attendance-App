import 'package:dartz/dartz.dart';

import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/data/models/reference/announcement.dart';
import 'package:attendance/data/models/reference/office.dart';
import 'package:attendance/data/models/user/user.dart';

abstract class ProfileRepository {
  Future<Either<Failure, User>> me();
  Future<Either<Failure, NotificationFeed>> notifications({bool unreadOnly});
  Future<Either<Failure, Unit>> markNotificationRead(int id);
  Future<Either<Failure, List<Announcement>>> announcements();
  Future<Either<Failure, List<Office>>> offices();
}
