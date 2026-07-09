import 'package:json_annotation/json_annotation.dart';

import 'package:attendance/data/models/attendance/shift.dart';

part 'user.g.dart';

/// `GET /api/me`.
@JsonSerializable()
class User {
  final int id;
  final String nik;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? department;
  final String? position;

  /// Not in the contract's `required` list, so nullable.
  final DateTime? joinedAt;

  final Shift shift;
  final int? officeId;

  const User({
    required this.id,
    required this.nik,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.department,
    this.position,
    this.joinedAt,
    required this.shift,
    this.officeId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
