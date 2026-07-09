import 'package:json_annotation/json_annotation.dart';

part 'office.g.dart';

/// `GET /api/office/locations`. The client checks distance against these before
/// enabling check-in, but that is a UX affordance only — the server re-validates
/// and is the authority.
@JsonSerializable()
class Office {
  final int id;
  final String name;

  /// Not in the contract's `required` list.
  final String? address;

  final double lat;
  final double lng;
  final int radiusMeters;
  final String timeZone;

  const Office({
    required this.id,
    required this.name,
    this.address,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    required this.timeZone,
  });

  factory Office.fromJson(Map<String, dynamic> json) => _$OfficeFromJson(json);

  Map<String, dynamic> toJson() => _$OfficeToJson(this);
}
