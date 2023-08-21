part of 'avail_bloc.dart';

abstract class AvailState extends Equatable {
  const AvailState();

  @override
  List<Object> get props => [];
}

class AvailInitial extends AvailState {}

class LoadingGetAvailState extends AvailState {}

class LoadedGetAvailState extends AvailState {
  final BaseAvail result;

  const LoadedGetAvailState({required this.result});

  @override
  List<Object> get props => [result];
}

class ErrorGetAvailState extends AvailState {
  final String message;
  final String token;

  const ErrorGetAvailState({
    required this.message,
    required this.token,
  });

  @override
  List<Object> get props => [message, token];
}
