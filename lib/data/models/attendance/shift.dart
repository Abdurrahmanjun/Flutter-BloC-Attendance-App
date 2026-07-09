import 'package:json_annotation/json_annotation.dart';

part 'shift.g.dart';

@JsonSerializable()
class Shift {
  /// `HH:mm`.
  final String start;
  final String end;

  /// IANA name. Defines which calendar day a punch belongs to.
  final String timeZone;

  const Shift({
    required this.start,
    required this.end,
    required this.timeZone,
  });

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);

  Map<String, dynamic> toJson() => _$ShiftToJson(this);
}
