// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_balance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) => LeaveBalance(
      type: $enumDecode(_$LeaveTypeEnumMap, json['type']),
      entitledDays: (json['entitledDays'] as num).toInt(),
      usedDays: (json['usedDays'] as num).toInt(),
      remainingDays: (json['remainingDays'] as num).toInt(),
    );

Map<String, dynamic> _$LeaveBalanceToJson(LeaveBalance instance) =>
    <String, dynamic>{
      'type': _$LeaveTypeEnumMap[instance.type]!,
      'entitledDays': instance.entitledDays,
      'usedDays': instance.usedDays,
      'remainingDays': instance.remainingDays,
    };

const _$LeaveTypeEnumMap = {
  LeaveType.annual: 'annual',
  LeaveType.sick: 'sick',
  LeaveType.unpaid: 'unpaid',
  LeaveType.maternity: 'maternity',
};
