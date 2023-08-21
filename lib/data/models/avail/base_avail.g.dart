// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_avail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseAvail _$BaseAvailFromJson(Map<String, dynamic> json) => BaseAvail(
      code: json['code'] as int?,
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BaseAvailToJson(BaseAvail instance) => <String, dynamic>{
      'code': instance.code,
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };
