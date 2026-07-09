// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      nik: json['nik'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      department: json['department'] as String?,
      position: json['position'] as String?,
      joinedAt: json['joinedAt'] == null
          ? null
          : DateTime.parse(json['joinedAt'] as String),
      shift: Shift.fromJson(json['shift'] as Map<String, dynamic>),
      officeId: (json['officeId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'nik': instance.nik,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'department': instance.department,
      'position': instance.position,
      'joinedAt': instance.joinedAt?.toIso8601String(),
      'shift': instance.shift,
      'officeId': instance.officeId,
    };
