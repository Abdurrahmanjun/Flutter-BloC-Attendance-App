// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    AppNotification(
      id: (json['id'] as num).toInt(),
      kind: $enumDecode(_$NotificationKindEnumMap, json['kind']),
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$NotificationKindEnumMap[instance.kind]!,
      'title': instance.title,
      'body': instance.body,
      'createdAt': instance.createdAt.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

const _$NotificationKindEnumMap = {
  NotificationKind.attendanceLate: 'attendance_late',
  NotificationKind.attendanceMissingCheckout: 'attendance_missing_checkout',
  NotificationKind.leaveApproved: 'leave_approved',
  NotificationKind.leaveRejected: 'leave_rejected',
  NotificationKind.overtimeRequest: 'overtime_request',
  NotificationKind.overtimeApproved: 'overtime_approved',
  NotificationKind.announcement: 'announcement',
};

NotificationFeed _$NotificationFeedFromJson(Map<String, dynamic> json) =>
    NotificationFeed(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$NotificationFeedToJson(NotificationFeed instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'unreadCount': instance.unreadCount,
    };
