part of 'destination_bloc.dart';

abstract class DestinationEvent extends Equatable {
  const DestinationEvent();

  @override
  List<Object> get props => [];
}

class SetDestinationEvent extends DestinationEvent {
  final String token;

  const SetDestinationEvent({required this.token});
  @override
  List<Object> get props => [token];
}

class GetDestinationEvent extends DestinationEvent {
  final String token;

  const GetDestinationEvent({required this.token});
  @override
  List<Object> get props => [token];
}

class SearchEvent extends DestinationEvent {
  final String key;
  final List<Destination> data;
  final String token;

  const SearchEvent({
    required this.key,
    required this.data,
    required this.token,
  });

  @override
  List<Object> get props => [
        key,
        data,
        token,
      ];
}
