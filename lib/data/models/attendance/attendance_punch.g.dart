// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_punch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendancePunch _$AttendancePunchFromJson(Map<String, dynamic> json) =>
    AttendancePunch(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp:
          const _Rfc3339Converter().fromJson(json['timestamp'] as String),
      note: json['note'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );

Map<String, dynamic> _$AttendancePunchToJson(AttendancePunch instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'timestamp': const _Rfc3339Converter().toJson(instance.timestamp),
      'note': instance.note,
      'photoUrl': instance.photoUrl,
    };
