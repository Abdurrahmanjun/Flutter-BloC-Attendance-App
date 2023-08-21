part of 'destination_bloc.dart';

abstract class DestinationState extends Equatable {
  const DestinationState();

  @override
  List<Object> get props => [];
}

class DestinationInitial extends DestinationState {}

class LoadingSetDestinationState extends DestinationState {}

class LoadingGetDestinationState extends DestinationState {}

class LoadedGetDestinationState extends DestinationState {
  final List<Destination> result;
  final String token;

  const LoadedGetDestinationState({
    required this.result,
    required this.token,
  });

  @override
  List<Object> get props => [
        result,
        token,
      ];
}

class ErrorGetDestinationState extends DestinationState {
  final String message;
  final String token;

  const ErrorGetDestinationState({
    required this.message,
    required this.token,
  });

  @override
  List<Object> get props => [message, token];
}

class LoadingSearchState extends DestinationState {}

class LoadedSearchState extends DestinationState {
  final List<Destination> oldData;
  final List<Destination> result;
  final String token;

  const LoadedSearchState({
    required this.oldData,
    required this.result,
    required this.token,
  });
  @override
  List<Object> get props => [
        oldData,
        result,
        token,
      ];
}
