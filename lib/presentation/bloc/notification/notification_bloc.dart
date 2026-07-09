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
}
