// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseDestination _$BaseDestinationFromJson(Map<String, dynamic> json) =>
    BaseDestination(
      code: json['code'] as int?,
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Destination.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BaseDestinationToJson(BaseDestination instance) =>
    <String, dynamic>{
      'code': instance.code,
      'status': instance.status,
      'message': instance.message,
      'data': instance.data,
    };
