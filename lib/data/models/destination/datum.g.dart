// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Destination _$DestinationFromJson(Map<String, dynamic> json) => Destination(
      destinationId: json['destination_id'] as int?,
      typeSource: json['type_source'] as String?,
      typeName: json['type_name'] as String?,
      name: json['name'] as String?,
      packageTypeId: json['package_type_id'] as int?,
    );

Map<String, dynamic> _$DestinationToJson(Destination instance) =>
    <String, dynamic>{
      'destination_id': instance.destinationId,
      'type_source': instance.typeSource,
      'type_name': instance.typeName,
      'name': instance.name,
      'package_type_id': instance.packageTypeId,
    };
