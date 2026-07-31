import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// `GET /api/notifications`, replacing the hardcoded five-item feed.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationReadUseCase,
  }) : super(NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<MarkNotificationReadEvent>(_onMarkRead);
    on<MarkAllNotificationsReadEvent>(_onMarkAllRead);
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    final either = await getNotificationsUseCase();
    emit(either.fold(
      (failure) => NotificationFailure(failure.message),
      (feed) => NotificationLoaded(
        notifications: feed.notifications,
        unreadCount: feed.unreadCount,
      ),
    ));
  }

  Future<void> _onMarkRead(
    MarkNotificationReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final either = await markNotificationReadUseCase(event.id);
    // Re-read rather than mutate locally: the server owns readAt and
    // unreadCount. On failure leave the list exactly as it was.
    if (either.isRight()) add(LoadNotificationsEvent());
  }

  /// "Tandai semua". No bulk endpoint exists, so this is a fan-out over the
  /// per-item one. The calls go out together, and the feed is re-read once at
  /// the end rather than after each — a partial failure just leaves those items
  /// unread, which the reload will show accurately.
  Future<void> _onMarkAllRead(
    MarkAllNotificationsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is! NotificationLoaded) return;

    final unread = current.notifications.where((n) => n.isUnread).toList();
    if (unread.isEmpty) return;

    await Future.wait(unread.map((n) => markNotificationReadUseCase(n.id)));
    add(LoadNotificationsEvent());
  }
}
