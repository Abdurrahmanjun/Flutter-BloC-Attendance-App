part of 'last_destination_bloc.dart';

abstract class LastDestinationState extends Equatable {
  const LastDestinationState();

  @override
  List<Object> get props => [];
}

class LastDestinationInitial extends LastDestinationState {}

class LoadingSetLastDestinationState extends LastDestinationState {}

class LoadedSetLastDestinationState extends LastDestinationState {}

class ErrorSetLastDestinationState extends LastDestinationState {
  final String message;

  const ErrorSetLastDestinationState({required this.message});

  @override
  List<Object> get props => [message];
}

class LoadingGetLastDestinationState extends LastDestinationState {}

class LoadedGetLastDestinationState extends LastDestinationState {
  final List<Destination> result;

  const LoadedGetLastDestinationState({required this.result});

  @override
  List<Object> get props => [result];
}

class ErrorGetLastDestinationState extends LastDestinationState {
  final String message;

  const ErrorGetLastDestinationState({required this.message});

  @override
  List<Object> get props => [message];
}
