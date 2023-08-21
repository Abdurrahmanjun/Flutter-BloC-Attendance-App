part of 'promo_bloc.dart';

abstract class PromoEvent extends Equatable {
  const PromoEvent();

  @override
  List<Object> get props => [];
}

class RunSliderEvent extends PromoEvent {
  final int id;

  const RunSliderEvent({required this.id});

  @override
  List<Object> get props => [id];
}
