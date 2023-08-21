part of 'promo_bloc.dart';

abstract class PromoState extends Equatable {
  const PromoState();

  @override
  List<Object> get props => [];
}

class PromoInitial extends PromoState {}

class LoadedSliderState extends PromoState {
  final int id;

  const LoadedSliderState({required this.id});

  @override
  List<Object> get props => [id];
}
