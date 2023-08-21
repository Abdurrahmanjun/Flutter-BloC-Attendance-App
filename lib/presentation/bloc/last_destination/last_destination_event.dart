part of 'last_destination_bloc.dart';

abstract class LastDestinationEvent extends Equatable {
  const LastDestinationEvent();

  @override
  List<Object> get props => [];
}

class SetLastDestinationEvent extends LastDestinationEvent {
  final Destination destination;

  const SetLastDestinationEvent({required this.destination});
  @override
  List<Object> get props => [destination];
}

class GetLastDestinationEvent extends LastDestinationEvent {}
