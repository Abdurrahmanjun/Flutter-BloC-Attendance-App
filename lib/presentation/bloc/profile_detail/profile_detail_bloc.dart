import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/data/models/leave/leave_balance.dart';
import 'package:attendance/data/models/reference/office.dart';
import 'package:attendance/data/models/user/user.dart';
import 'package:attendance/domain/usecases/attendance_use_cases.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';
import 'package:attendance/presentation/bloc/attendance/summary_bloc.dart';

part 'profile_detail_event.dart';
part 'profile_detail_state.dart';

/// Everything the Profil screen shows, which spans four endpoints.
///
/// Separate from [ProfileBloc], which is just `GET /api/me` and is read by the
/// home greeting on every load — this screen's extra three calls have no
/// business slowing that down.
///
/// Only `/api/me` can fail the screen; the stat cells degrade individually
/// because a missing leave balance should not hide the user's own name.
class ProfileDetailBloc extends Bloc<ProfileDetailEvent, ProfileDetailState> {
  final GetMeUseCase getMeUseCase;
  final GetLeaveBalanceUseCase getLeaveBalanceUseCase;
  final GetOfficesUseCase getOfficesUseCase;
  final GetAttendanceSummaryUseCase getAttendanceSummaryUseCase;

  ProfileDetailBloc({
    required this.getMeUseCase,
    required this.getLeaveBalanceUseCase,
    required this.getOfficesUseCase,
    required this.getAttendanceSummaryUseCase,
  }) : super(ProfileDetailInitial()) {
    on<LoadProfileDetailEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadProfileDetailEvent event,
    Emitter<ProfileDetailState> emit,
  ) async {
    emit(ProfileDetailLoading());

    // Started together, awaited separately: none depends on another.
    final meCall = getMeUseCase();
    final balanceCall = getLeaveBalanceUseCase();
    final officesCall = getOfficesUseCase();
    final summaryCall =
        getAttendanceSummaryUseCase(SummaryBloc.currentMonth());

    final meEither = await meCall;
    final balanceEither = await balanceCall;
    final officesEither = await officesCall;
    final summaryEither = await summaryCall;

    final failure = meEither.swap().toOption().toNullable();
    if (failure != null) {
      emit(ProfileDetailFailure(failure.message));
      return;
    }

    emit(ProfileDetailLoaded(
      user: meEither.getOrElse(() => throw StateError('checked above')),
      balances: balanceEither.getOrElse(() => const <LeaveBalance>[]),
      offices: officesEither.getOrElse(() => const <Office>[]),
      summary: summaryEither.toOption().toNullable(),
    ));
  }
}
