part of 'avail_bloc.dart';

abstract class AvailEvent extends Equatable {
  const AvailEvent();

  @override
  List<Object> get props => [];
}

class GetAvailEvent extends AvailEvent {
  final String token;
  final int typeId;

  const GetAvailEvent({
    required this.token,
    required this.typeId,
  });

  @override
  List<Object> get props => [
        token,
        typeId,
      ];
}
