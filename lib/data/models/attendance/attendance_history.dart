import 'package:json_annotation/json_annotation.dart';

import 'package:attendance/data/models/attendance/attendance_entry.dart';

part 'attendance_history.g.dart';

/// `data` of `GET /api/attendance/history` — a page of entries, newest first.
@JsonSerializable()
class AttendanceHistory {
  final List<AttendanceEntry> entries;
  final int page;
  final int perPage;
  final int totalPages;
  final int totalEntries;

  const AttendanceHistory({
    required this.entries,
    required this.page,
    required this.perPage,
    required this.totalPages,
    required this.totalEntries,
  });

  bool get hasMore => page < totalPages;

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) =>
      _$AttendanceHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceHistoryToJson(this);
}
