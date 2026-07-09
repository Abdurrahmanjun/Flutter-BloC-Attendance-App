import 'package:json_annotation/json_annotation.dart';

part 'monthly_summary.g.dart';

/// `GET /api/attendance/summary?month=YYYY-MM`.
///
/// `late` is a **subset** of `present` — a late day is still a present day.
/// Summing present + late + absent + leave overcounts; don't.
@JsonSerializable()
class MonthlySummary {
  final String month;
  final int workingDays;
  final int present;
  final int late;
  final int absent;
  final int leave;

  @JsonKey(defaultValue: 0)
  final int overtimeMinutes;

  /// `HH:mm`, null when there is nothing to average.
  final String? averageCheckInTime;

  const MonthlySummary({
    required this.month,
    required this.workingDays,
    required this.present,
    required this.late,
    required this.absent,
    required this.leave,
    this.overtimeMinutes = 0,
    this.averageCheckInTime,
  });

  /// Present days that were on time.
  int get onTime => present - late;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      _$MonthlySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlySummaryToJson(this);
}
