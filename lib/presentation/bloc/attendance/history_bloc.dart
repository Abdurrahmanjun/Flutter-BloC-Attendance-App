import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/domain/usecases/attendance_use_cases.dart';

part 'history_event.dart';
part 'history_state.dart';

/// `GET /api/attendance/history`, paginated, newest first.
///
/// The contract scopes the feed with `from`/`to`, so a month view asks the
/// server for that month rather than paging backwards until it shows up.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;

  /// The month currently scoping the feed, or null while it is unscoped.
  DateTime? _month;

  HistoryBloc({required this.getAttendanceHistoryUseCase})
      : super(HistoryInitial()) {
    on<LoadHistoryEvent>(_onLoad);
    on<LoadMoreHistoryEvent>(_onLoadMore);
  }

  /// `YYYY-MM-DD` for the first and last day of [month].
  static (String from, String to) monthRange(DateTime month) {
    String fmt(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    // Day 0 of the next month is the last day of this one — leap years and
    // 30-day months included, without a table.
    return (
      fmt(DateTime(month.year, month.month, 1)),
      fmt(DateTime(month.year, month.month + 1, 0)),
    );
  }

  Future<void> _onLoad(
    LoadHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    _month = event.month;
    emit(HistoryLoading());

    final range = _month == null ? null : monthRange(_month!);
    final either = await getAttendanceHistoryUseCase(
      from: range?.$1,
      to: range?.$2,
      page: 1,
    );

    emit(either.fold(
      (failure) => HistoryFailure(failure.message),
      (page) => HistoryLoaded(
        entries: page.entries,
        page: page.page,
        hasMore: page.hasMore,
        totalEntries: page.totalEntries,
        month: _month,
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

    final range = _month == null ? null : monthRange(_month!);
    final either = await getAttendanceHistoryUseCase(
      from: range?.$1,
      to: range?.$2,
      page: current.page + 1,
    );

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
          month: current.month,
        );
      },
    ));
  }
}
