import 'package:dartz/dartz.dart';

import 'package:attendance/common/error/error_mapper.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/datasources/profile_remote_data_source.dart';
import 'package:attendance/data/models/leave/leave_balance.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/data/models/reference/announcement.dart';
import 'package:attendance/data/models/reference/office.dart';
import 'package:attendance/data/models/user/user.dart';
import 'package:attendance/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> me() => _guard(remoteDataSource.me);

  @override
  Future<Either<Failure, NotificationFeed>> notifications({
    bool unreadOnly = false,
  }) =>
      _guard(() => remoteDataSource.notifications(unreadOnly: unreadOnly));

  @override
  Future<Either<Failure, Unit>> markNotificationRead(int id) => _guard(() async {
        await remoteDataSource.markNotificationRead(id);
        return unit;
      });

  @override
  Future<Either<Failure, List<Announcement>>> announcements() =>
      _guard(remoteDataSource.announcements);

  @override
  Future<Either<Failure, List<Office>>> offices() =>
      _guard(remoteDataSource.offices);

  @override
  Future<Either<Failure, List<LeaveBalance>>> leaveBalance() =>
      _guard(remoteDataSource.leaveBalance);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } catch (error) {
      return Left(mapError(error));
    }
  }
}
