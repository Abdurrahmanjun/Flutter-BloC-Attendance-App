import 'package:json_annotation/json_annotation.dart';

part 'attendance_entry.g.dart';

enum EntryStatus {
  @JsonValue('present')
  present,
  @JsonValue('absent')
  absent,
  @JsonValue('leave')
  leave,
  @JsonValue('holiday')
  holiday,
}

/// One day's record. Note there is no `late` status: lateness is the [isLate]
/// flag on a `present` day. A late day is still a day you showed up.
@JsonSerializable()
class AttendanceEntry {
  final int id;
  final DateTime date;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final EntryStatus status;
  final bool isLate;

  @JsonKey(defaultValue: 0)
  final int lateByMinutes;
  final int workedMinutes;
  @JsonKey(defaultValue: 0)
  final int overtimeMinutes;

  final int? officeId;

  const AttendanceEntry({
    required this.id,
    required this.date,
    this.checkInAt,
    this.checkOutAt,
    required this.status,
    required this.isLate,
    this.lateByMinutes = 0,
    required this.workedMinutes,
    this.overtimeMinutes = 0,
    this.officeId,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) =>
      _$AttendanceEntryFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceEntryToJson(this);
}
