// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceHistory _$AttendanceHistoryFromJson(Map<String, dynamic> json) =>
    AttendanceHistory(
      entries: (json['entries'] as List<dynamic>)
          .map((e) => AttendanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num).toInt(),
      perPage: (json['perPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      totalEntries: (json['totalEntries'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceHistoryToJson(AttendanceHistory instance) =>
    <String, dynamic>{
      'entries': instance.entries,
      'page': instance.page,
      'perPage': instance.perPage,
      'totalPages': instance.totalPages,
      'totalEntries': instance.totalEntries,
    };
