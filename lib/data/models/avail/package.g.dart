// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Package _$PackageFromJson(Map<String, dynamic> json) => Package(
      packageId: json['package_id'] as int?,
      name: json['name'] as String?,
      price: json['price'] as int?,
      currency: json['currency'] as String?,
      day: json['day'] as int?,
      operationTimeIn: json['operation_time_in'] as String?,
      operationTimeOut: json['operation_time_out'] as String?,
      timeZone: json['time_zone'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      packageTypeId: json['package_type_id'] as int?,
      packageTypeName: json['package_type_name'] as String?,
      isInstallment: json['is_installment'] as bool?,
      destinations: (json['destinations'] as List<dynamic>?)
          ?.map((e) => Destination.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PackageToJson(Package instance) => <String, dynamic>{
      'package_id': instance.packageId,
      'name': instance.name,
      'price': instance.price,
      'currency': instance.currency,
      'day': instance.day,
      'operation_time_in': instance.operationTimeIn,
      'operation_time_out': instance.operationTimeOut,
      'time_zone': instance.timeZone,
      'images': instance.images,
      'package_type_id': instance.packageTypeId,
      'package_type_name': instance.packageTypeName,
      'is_installment': instance.isInstallment,
      'destinations': instance.destinations,
    };
