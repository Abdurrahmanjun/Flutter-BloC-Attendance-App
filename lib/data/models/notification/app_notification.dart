import 'package:json_annotation/json_annotation.dart';

part 'app_notification.g.dart';

enum NotificationKind {
  @JsonValue('attendance_late')
  attendanceLate,
  @JsonValue('attendance_missing_checkout')
  attendanceMissingCheckout,
  @JsonValue('leave_approved')
  leaveApproved,
  @JsonValue('leave_rejected')
  leaveRejected,
  @JsonValue('overtime_request')
  overtimeRequest,
  @JsonValue('overtime_approved')
  overtimeApproved,
  @JsonValue('announcement')
  announcement,
}

/// Named `AppNotification` because `Notification` is a Flutter widget class.
@JsonSerializable()
class AppNotification {
  final int id;
  final NotificationKind kind;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.readAt,
  });

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);
}

/// `data` of `GET /api/notifications`.
@JsonSerializable()
class NotificationFeed {
  final List<AppNotification> notifications;
  final int unreadCount;

  const NotificationFeed({
    required this.notifications,
    required this.unreadCount,
  });

  factory NotificationFeed.fromJson(Map<String, dynamic> json) =>
      _$NotificationFeedFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationFeedToJson(this);
}
