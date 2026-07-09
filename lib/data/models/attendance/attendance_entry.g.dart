// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceEntry _$AttendanceEntryFromJson(Map<String, dynamic> json) =>
    AttendanceEntry(
      id: (json['id'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      checkInAt: json['checkInAt'] == null
          ? null
          : DateTime.parse(json['checkInAt'] as String),
      checkOutAt: json['checkOutAt'] == null
          ? null
          : DateTime.parse(json['checkOutAt'] as String),
      status: $enumDecode(_$EntryStatusEnumMap, json['status']),
      isLate: json['isLate'] as bool,
      lateByMinutes: (json['lateByMinutes'] as num?)?.toInt() ?? 0,
      workedMinutes: (json['workedMinutes'] as num).toInt(),
      overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt() ?? 0,
      officeId: (json['officeId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AttendanceEntryToJson(AttendanceEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'checkInAt': instance.checkInAt?.toIso8601String(),
      'checkOutAt': instance.checkOutAt?.toIso8601String(),
      'status': _$EntryStatusEnumMap[instance.status]!,
      'isLate': instance.isLate,
      'lateByMinutes': instance.lateByMinutes,
      'workedMinutes': instance.workedMinutes,
      'overtimeMinutes': instance.overtimeMinutes,
      'officeId': instance.officeId,
    };

const _$EntryStatusEnumMap = {
  EntryStatus.present: 'present',
  EntryStatus.absent: 'absent',
  EntryStatus.leave: 'leave',
  EntryStatus.holiday: 'holiday',
};
