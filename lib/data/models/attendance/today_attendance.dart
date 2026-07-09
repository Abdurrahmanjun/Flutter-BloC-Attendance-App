import 'package:json_annotation/json_annotation.dart';

import 'package:attendance/data/models/attendance/shift.dart';

part 'today_attendance.g.dart';

enum TodayStatus {
  @JsonValue('not_checked_in')
  notCheckedIn,
  @JsonValue('checked_in')
  checkedIn,
  @JsonValue('checked_out')
  checkedOut,
}

/// `GET /api/attendance/today` — the client's primary call, and what decides
/// which action the home screen's main button offers.
@JsonSerializable()
class TodayAttendance {
  final DateTime date;
  final TodayStatus status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final bool isLate;

  /// Not in the contract's `required` list, so defaulted.
  @JsonKey(defaultValue: 0)
  final int lateByMinutes;

  /// Computed against the server clock while `checked_in`, so it advances
  /// between polls. Refresh after any punch rather than deriving it locally.
  final int workedMinutes;

  final Shift shift;

  const TodayAttendance({
    required this.date,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
    required this.isLate,
    this.lateByMinutes = 0,
    required this.workedMinutes,
    required this.shift,
  });

  bool get canCheckIn => status == TodayStatus.notCheckedIn;
  bool get canCheckOut => status == TodayStatus.checkedIn;
  bool get isDone => status == TodayStatus.checkedOut;

  factory TodayAttendance.fromJson(Map<String, dynamic> json) =>
      _$TodayAttendanceFromJson(json);

  Map<String, dynamic> toJson() => _$TodayAttendanceToJson(this);
}
