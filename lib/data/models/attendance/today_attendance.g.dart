// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_attendance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayAttendance _$TodayAttendanceFromJson(Map<String, dynamic> json) =>
    TodayAttendance(
      date: DateTime.parse(json['date'] as String),
      status: $enumDecode(_$TodayStatusEnumMap, json['status']),
      checkInAt: json['checkInAt'] == null
          ? null
          : DateTime.parse(json['checkInAt'] as String),
      checkOutAt: json['checkOutAt'] == null
          ? null
          : DateTime.parse(json['checkOutAt'] as String),
      isLate: json['isLate'] as bool,
      lateByMinutes: (json['lateByMinutes'] as num?)?.toInt() ?? 0,
      workedMinutes: (json['workedMinutes'] as num).toInt(),
      shift: Shift.fromJson(json['shift'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TodayAttendanceToJson(TodayAttendance instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'status': _$TodayStatusEnumMap[instance.status]!,
      'checkInAt': instance.checkInAt?.toIso8601String(),
      'checkOutAt': instance.checkOutAt?.toIso8601String(),
      'isLate': instance.isLate,
      'lateByMinutes': instance.lateByMinutes,
      'workedMinutes': instance.workedMinutes,
      'shift': instance.shift,
    };

const _$TodayStatusEnumMap = {
  TodayStatus.notCheckedIn: 'not_checked_in',
  TodayStatus.checkedIn: 'checked_in',
  TodayStatus.checkedOut: 'checked_out',
};
