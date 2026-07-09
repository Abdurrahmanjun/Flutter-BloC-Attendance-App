import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/domain/usecases/attendance_use_cases.dart';

part 'summary_event.dart';
part 'summary_state.dart';

/// `GET /api/attendance/summary?month=YYYY-MM`, which feeds the dashboard's
/// diagram card.
class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final GetAttendanceSummaryUseCase getAttendanceSummaryUseCase;

  SummaryBloc({required this.getAttendanceSummaryUseCase})
      : super(SummaryInitial()) {
    on<LoadSummaryEvent>((event, emit) async {
      emit(SummaryLoading());
      final either = await getAttendanceSummaryUseCase(event.month);
      emit(either.fold(
        (failure) => SummaryFailure(failure.message),
        (summary) => SummaryLoaded(summary),
      ));
    });
  }

  /// The current month as the contract's `YYYY-MM`.
  static String currentMonth([DateTime? now]) {
    final date = now ?? DateTime.now();
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }
}
