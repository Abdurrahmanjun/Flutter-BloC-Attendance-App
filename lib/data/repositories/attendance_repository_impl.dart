import 'package:dartz/dartz.dart';

import 'package:attendance/common/error/error_mapper.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/common/location/location_service.dart';
import 'package:attendance/common/network/api_response.dart';
import 'package:attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/data/models/attendance/attendance_history.dart';
import 'package:attendance/data/models/attendance/attendance_punch.dart';
import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';
import 'package:attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final LocationService locationService;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.locationService,
  });

  @override
  Future<Either<Failure, TodayAttendance>> today() =>
      _guard(() => remoteDataSource.today());

  @override
  Future<Either<Failure, PunchResult>> checkIn() =>
      _punch(remoteDataSource.checkIn);

  @override
  Future<Either<Failure, PunchResult>> checkOut() =>
      _punch(remoteDataSource.checkOut);

  @override
  Future<Either<Failure, AttendanceHistory>> history({
    int page = 1,
    int perPage = 20,
  }) =>
      _guard(() => remoteDataSource.history(page: page, perPage: perPage));

  @override
  Future<Either<Failure, MonthlySummary>> summary(String month) =>
      _guard(() => remoteDataSource.summary(month));

  /// Takes a GPS fix, then punches. The device timestamp travels with it but is
  /// advisory — the server records its own clock and stores the skew.
  Future<Either<Failure, PunchResult>> _punch(
    Future<ApiResponse<AttendanceEntry>> Function(AttendancePunch) send,
  ) async {
    final AttendancePunch punch;
    try {
      final position = await locationService.currentPosition();
      punch = AttendancePunch(
        lat: position.latitude,
        lng: position.longitude,
        timestamp: DateTime.now(),
      );
    } on LocationException catch (error) {
      return Left(LocationFailure(error.message));
    }

    return _guard(() async {
      final envelope = await send(punch);
      return PunchResult(entry: envelope.data!, message: envelope.message);
    });
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } catch (error) {
      return Left(mapError(error));
    }
  }
}
