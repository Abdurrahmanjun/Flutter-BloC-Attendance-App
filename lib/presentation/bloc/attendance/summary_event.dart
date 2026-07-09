part of 'summary_bloc.dart';

abstract class SummaryEvent extends Equatable {
  const SummaryEvent();

  @override
  List<Object> get props => [];
}

class LoadSummaryEvent extends SummaryEvent {
  /// `YYYY-MM`.
  final String month;

  const LoadSummaryEvent(this.month);

  @override
  List<Object> get props => [month];
}
