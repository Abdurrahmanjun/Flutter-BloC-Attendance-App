part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load page 1. With no [month] the feed is unscoped — the most recent entries,
/// whatever month they fall in — which is what the home screen's week strip
/// wants. Absensi passes a month so the server does the scoping, via the
/// contract's `from`/`to`.
class LoadHistoryEvent extends HistoryEvent {
  /// Any day inside the wanted month; only its year and month are read.
  final DateTime? month;

  const LoadHistoryEvent({this.month});

  @override
  List<Object?> get props => [month];
}

class LoadMoreHistoryEvent extends HistoryEvent {}
