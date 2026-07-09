import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/domain/usecases/attendance_use_cases.dart';

part 'history_event.dart';
part 'history_state.dart';

/// `GET /api/attendance/history`, paginated, newest first.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;

  HistoryBloc({required this.getAttendanceHistoryUseCase})
      : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoad);
    on<LoadMoreHistoryEvent>(_onLoadMore);
  }

  Future<void> _onLoad(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final either = await getAttendanceHistoryUseCase(page: 1);
    emit(either.fold(
      (failure) => HistoryFailure(failure.message),
      (page) => HistoryLoaded(
        entries: page.entries,
        page: page.page,
        hasMore: page.hasMore,
        totalEntries: page.totalEntries,
      ),
    ));
  }

  Future<void> _onLoadMore(
    LoadMoreHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final current = state;
    if (current is! HistoryLoaded || !current.hasMore || current.loadingMore) {
      return;
    }

    emit(current.copyWith(loadingMore: true));
    final either = await getAttendanceHistoryUseCase(page: current.page + 1);

    emit(either.fold(
      // Keep the rows already on screen; a failed "load more" should not wipe
      // the list the user is looking at.
      (failure) => current.copyWith(loadingMore: false),
      (page) {
        // If the server echoes back a page we already have, it ignored `page`
        // — appending would duplicate rows forever, once per scroll. Stop
        // instead. The Prism mock does exactly this.
        if (page.page <= current.page) {
          return current.copyWith(loadingMore: false, hasMore: false);
        }
        return HistoryLoaded(
          entries: [...current.entries, ...page.entries],
          page: page.page,
          hasMore: page.hasMore,
          totalEntries: page.totalEntries,
        );
      },
    ));
  }
}
