// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseLogin _$BaseLoginFromJson(Map<String, dynamic> json) => BaseLogin(
      code: json['code'] as int?,
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BaseLoginToJson(BaseLogin instance) => <String, dynamic>{
      'code': instance.code,
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };
