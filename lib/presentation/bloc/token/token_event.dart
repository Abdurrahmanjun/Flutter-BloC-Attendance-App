part of 'token_bloc.dart';

abstract class TokenEvent extends Equatable {
  const TokenEvent();

  @override
  List<Object> get props => [];
}

class SetTokenEvent extends TokenEvent {
  final String username;
  final String password;

  const SetTokenEvent({
    required this.username,
    required this.password,
  });
}

class GetTokenEvent extends TokenEvent {}
