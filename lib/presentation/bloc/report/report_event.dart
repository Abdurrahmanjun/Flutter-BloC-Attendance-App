part of 'report_bloc.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReportEvent extends ReportEvent {
  /// Any day inside the wanted month; only its year and month are read.
  final DateTime month;

  const LoadReportEvent(this.month);

  @override
  List<Object?> get props => [month.year, month.month];
}
