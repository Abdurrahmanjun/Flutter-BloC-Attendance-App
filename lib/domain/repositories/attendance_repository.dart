import 'package:dartz/dartz.dart';

import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/data/models/attendance/attendance_history.dart';
import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';

/// A successful punch, plus the server's human-readable confirmation.
class PunchResult {
  final AttendanceEntry entry;
  final String message;

  const PunchResult({required this.entry, required this.message});
}

abstract class AttendanceRepository {
  Future<Either<Failure, TodayAttendance>> today();

  /// A second check-in on the same calendar day yields [ConflictFailure];
  /// a check-in outside the office geofence yields [ValidationFailure] whose
  /// message carries the measured distance.
  Future<Either<Failure, PunchResult>> checkIn();

  Future<Either<Failure, PunchResult>> checkOut();

  /// [from] and [to] are `YYYY-MM-DD`, inclusive; the contract scopes the
  /// feed with them so a month view does not have to page to reach itself.
  Future<Either<Failure, AttendanceHistory>> history({
    String? from,
    String? to,
    int page,
    int perPage,
  });

  /// [month] is `YYYY-MM`.
  Future<Either<Failure, MonthlySummary>> summary(String month);
}
