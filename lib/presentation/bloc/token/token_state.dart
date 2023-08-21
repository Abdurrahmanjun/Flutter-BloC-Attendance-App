part of 'token_bloc.dart';

abstract class TokenState extends Equatable {
  const TokenState();

  @override
  List<Object> get props => [];
}

class TokenInitial extends TokenState {}

class LoadingGetTokenState extends TokenState {}

class LoadedGetTokenState extends TokenState {
  final String token;

  const LoadedGetTokenState({required this.token});

  @override
  List<Object> get props => [token];
}

class ErrorGetTokenState extends TokenState {
  final String message;

  const ErrorGetTokenState({required this.message});

  @override
  List<Object> get props => [message];
}
