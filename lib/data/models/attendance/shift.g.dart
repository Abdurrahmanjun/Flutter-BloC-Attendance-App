// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shift _$ShiftFromJson(Map<String, dynamic> json) => Shift(
      start: json['start'] as String,
      end: json['end'] as String,
      timeZone: json['timeZone'] as String,
    );

Map<String, dynamic> _$ShiftToJson(Shift instance) => <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
      'timeZone': instance.timeZone,
    };
