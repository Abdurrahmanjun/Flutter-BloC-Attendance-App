import 'package:json_annotation/json_annotation.dart';

part 'attendance_punch.g.dart';

/// Serialises as UTC so the wire format always carries an explicit offset.
/// `DateTime.toIso8601String()` on a *local* DateTime emits none, and the
/// contract's `format: date-time` requires one.
class _Rfc3339Converter implements JsonConverter<DateTime, String> {
  const _Rfc3339Converter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

/// Request body for check-in and check-out.
///
/// [timestamp] is advisory: the server records its own clock and stores the
/// skew for audit. Otherwise a user changes their phone clock and is never
/// late again.
// `note` and `photoUrl` serialise as explicit nulls rather than being omitted;
// the contract types them as nullable and its own check-in example sends
// `note: null`.
@JsonSerializable()
@_Rfc3339Converter()
class AttendancePunch {
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String? note;
  final String? photoUrl;

  const AttendancePunch({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.note,
    this.photoUrl,
  });

  factory AttendancePunch.fromJson(Map<String, dynamic> json) =>
      _$AttendancePunchFromJson(json);

  Map<String, dynamic> toJson() => _$AttendancePunchToJson(this);
}
