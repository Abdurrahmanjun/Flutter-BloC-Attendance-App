import 'package:dartz/dartz.dart';

import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/attendance/attendance_history.dart';
import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';
import 'package:attendance/domain/repositories/attendance_repository.dart';

class GetTodayAttendanceUseCase {
  final AttendanceRepository repository;
  GetTodayAttendanceUseCase(this.repository);

  Future<Either<Failure, TodayAttendance>> call() => repository.today();
}

class CheckInUseCase {
  final AttendanceRepository repository;
  CheckInUseCase(this.repository);

  Future<Either<Failure, PunchResult>> call() => repository.checkIn();
}

class CheckOutUseCase {
  final AttendanceRepository repository;
  CheckOutUseCase(this.repository);

  Future<Either<Failure, PunchResult>> call() => repository.checkOut();
}

class GetAttendanceHistoryUseCase {
  final AttendanceRepository repository;
  GetAttendanceHistoryUseCase(this.repository);

  Future<Either<Failure, AttendanceHistory>> call({
    int page = 1,
    int perPage = 20,
  }) =>
      repository.history(page: page, perPage: perPage);
}

class GetAttendanceSummaryUseCase {
  final AttendanceRepository repository;
  GetAttendanceSummaryUseCase(this.repository);

  Future<Either<Failure, MonthlySummary>> call(String month) =>
      repository.summary(month);
}
