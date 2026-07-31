part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object> get props => [];
}

class LoadNotificationsEvent extends NotificationEvent {}

class MarkNotificationReadEvent extends NotificationEvent {
  final int id;

  const MarkNotificationReadEvent(this.id);

  @override
  List<Object> get props => [id];
}

/// "Tandai semua". The contract has no bulk endpoint, so this fans out over
/// `POST /notifications/{id}/read` — one call per unread item.
class MarkAllNotificationsReadEvent extends NotificationEvent {}
