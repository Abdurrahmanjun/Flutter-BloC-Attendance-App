// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlySummary _$MonthlySummaryFromJson(Map<String, dynamic> json) =>
    MonthlySummary(
      month: json['month'] as String,
      workingDays: (json['workingDays'] as num).toInt(),
      present: (json['present'] as num).toInt(),
      late: (json['late'] as num).toInt(),
      absent: (json['absent'] as num).toInt(),
      leave: (json['leave'] as num).toInt(),
      overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt() ?? 0,
      averageCheckInTime: json['averageCheckInTime'] as String?,
    );

Map<String, dynamic> _$MonthlySummaryToJson(MonthlySummary instance) =>
    <String, dynamic>{
      'month': instance.month,
      'workingDays': instance.workingDays,
      'present': instance.present,
      'late': instance.late,
      'absent': instance.absent,
      'leave': instance.leave,
      'overtimeMinutes': instance.overtimeMinutes,
      'averageCheckInTime': instance.averageCheckInTime,
    };
