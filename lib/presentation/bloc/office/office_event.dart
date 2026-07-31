part of 'office_bloc.dart';

abstract class OfficeEvent extends Equatable {
  const OfficeEvent();

  @override
  List<Object> get props => [];
}

/// Take one measurement now.
class CheckProximityEvent extends OfficeEvent {}

/// Measure now, then keep re-measuring every [OfficeBloc.pollInterval] so the
/// home screen's distance meter tracks the user as they approach the office.
class WatchProximityEvent extends OfficeEvent {}

/// Stop the poll — the home screen is gone.
class StopWatchingProximityEvent extends OfficeEvent {}
