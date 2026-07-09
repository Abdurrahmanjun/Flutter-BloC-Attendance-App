part of 'today_bloc.dart';

abstract class TodayState extends Equatable {
  const TodayState();

  @override
  List<Object?> get props => [];
}

class TodayInitial extends TodayState {}

class TodayLoading extends TodayState {}

class TodayLoaded extends TodayState {
  final TodayAttendance today;

  /// A punch is in flight; the main button shows a spinner.
  final bool punching;

  const TodayLoaded(this.today, {this.punching = false});

  TodayLoaded copyWith({bool? punching}) =>
      TodayLoaded(today, punching: punching ?? this.punching);

  @override
  List<Object?> get props => [today, punching];
}

class TodayLoadFailure extends TodayState {
  final String message;

  const TodayLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Transient, for a snackbar. The bloc immediately re-reads `today` after.
class TodayPunchAccepted extends TodayState {
  final String message;

  const TodayPunchAccepted(this.message);

  @override
  List<Object?> get props => [message];
}

/// Transient. Covers 409 (already checked in) and 422 (outside the geofence);
/// [message] is the server's, verbatim. Never retried automatically.
class TodayPunchRejected extends TodayState {
  final String message;

  const TodayPunchRejected(this.message);

  @override
  List<Object?> get props => [message];
}
