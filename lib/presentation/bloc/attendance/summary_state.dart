part of 'summary_bloc.dart';

abstract class SummaryState extends Equatable {
  const SummaryState();

  @override
  List<Object?> get props => [];
}

class SummaryInitial extends SummaryState {}

class SummaryLoading extends SummaryState {}

class SummaryLoaded extends SummaryState {
  final MonthlySummary summary;

  const SummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary.month, summary.present, summary.late];
}

class SummaryFailure extends SummaryState {
  final String message;

  const SummaryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
