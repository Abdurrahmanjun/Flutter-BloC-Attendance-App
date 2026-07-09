import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';
import 'package:attendance/domain/repositories/attendance_repository.dart';
import 'package:attendance/domain/usecases/attendance_use_cases.dart';

part 'today_event.dart';
part 'today_state.dart';

/// Owns `GET /api/attendance/today` and the two punches.
///
/// After any punch the day is re-fetched rather than patched locally: the
/// server owns `workedMinutes` (it advances against the server clock while
/// `checked_in`) and it owns the calendar day the punch belongs to.
class TodayBloc extends Bloc<TodayEvent, TodayState> {
  final GetTodayAttendanceUseCase getTodayAttendanceUseCase;
  final CheckInUseCase checkInUseCase;
  final CheckOutUseCase checkOutUseCase;

  TodayBloc({
    required this.getTodayAttendanceUseCase,
    required this.checkInUseCase,
    required this.checkOutUseCase,
  }) : super(TodayInitial()) {
    on<LoadTodayEvent>(_onLoad);
    on<CheckInEvent>((event, emit) => _onPunch(emit, checkInUseCase.call));
    on<CheckOutEvent>((event, emit) => _onPunch(emit, checkOutUseCase.call));
  }

  Future<void> _onLoad(LoadTodayEvent event, Emitter<TodayState> emit) async {
    emit(TodayLoading());
    final either = await getTodayAttendanceUseCase();
    emit(either.fold(
      (failure) => TodayLoadFailure(failure.message),
      (today) => TodayLoaded(today),
    ));
  }

  Future<void> _onPunch(
    Emitter<TodayState> emit,
    Future<Either<Failure, PunchResult>> Function() punch,
  ) async {
    final current = state;
    if (current is TodayLoaded) emit(current.copyWith(punching: true));

    final either = await punch();

    either.fold(
      // 409 (already checked in) and 422 (outside the geofence) both arrive
      // here carrying the server's message verbatim — for 422 that string is
      // the only place the measured distance appears. Neither is retried.
      (failure) => emit(TodayPunchRejected(failure.message)),
      (result) => emit(TodayPunchAccepted(result.message)),
    );

    // Re-read the server's view either way: a 409 means our idea of the day was
    // stale, and a success moves us to the next state.
    add(LoadTodayEvent());
  }
}
