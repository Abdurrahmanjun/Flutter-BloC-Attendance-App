import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/data/models/leave/leave_balance.dart';
import 'package:attendance/domain/usecases/attendance_use_cases.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';
import 'package:attendance/presentation/bloc/attendance/history_bloc.dart';

part 'report_event.dart';
part 'report_state.dart';

/// The monthly report screen's data, which no single endpoint provides.
///
/// It composes four calls: this month's summary, the previous month's (for the
/// "naik 4,2% dari Juni" delta), the month's entries (total hours and the
/// arrival pattern, neither of which the summary carries), and the leave
/// balance.
///
/// The three secondary calls are best-effort — the screen still renders without
/// them — so only the summary can fail the whole screen.
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetAttendanceSummaryUseCase getAttendanceSummaryUseCase;
  final GetAttendanceHistoryUseCase getAttendanceHistoryUseCase;
  final GetLeaveBalanceUseCase getLeaveBalanceUseCase;

  ReportBloc({
    required this.getAttendanceSummaryUseCase,
    required this.getAttendanceHistoryUseCase,
    required this.getLeaveBalanceUseCase,
  }) : super(ReportInitial()) {
    on<LoadReportEvent>(_onLoad);
  }

  /// `YYYY-MM` for [month].
  static String monthKey(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}';

  Future<void> _onLoad(LoadReportEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());

    final month = DateTime(event.month.year, event.month.month);
    final previous = DateTime(month.year, month.month - 1);
    final range = HistoryBloc.monthRange(month);

    // Started together, awaited separately: they do not depend on each other,
    // and the screen cannot lay out until all four have landed.
    final summaryCall = getAttendanceSummaryUseCase(monthKey(month));
    final previousCall = getAttendanceSummaryUseCase(monthKey(previous));
    final historyCall = getAttendanceHistoryUseCase(
      from: range.$1,
      to: range.$2,
      perPage: 100,
    );
    final balanceCall = getLeaveBalanceUseCase();

    final summaryEither = await summaryCall;
    final previousEither = await previousCall;
    final historyEither = await historyCall;
    final balanceEither = await balanceCall;

    final failure = summaryEither.swap().toOption().toNullable();
    if (failure != null) {
      emit(ReportFailure(failure.message));
      return;
    }

    emit(ReportLoaded(
      month: month,
      summary: summaryEither.getOrElse(() => throw StateError('checked above')),
      // A missing previous month means no delta is shown, not an error — in a
      // user's first month there is nothing to compare against.
      previousSummary: previousEither.toOption().toNullable(),
      entries: historyEither
          .map((page) => page.entries)
          .getOrElse(() => const <AttendanceEntry>[]),
      balances: balanceEither.getOrElse(() => const <LeaveBalance>[]),
    ));
  }
}
