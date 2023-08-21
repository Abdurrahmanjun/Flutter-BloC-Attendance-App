part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class RunSliderEvent extends OnboardingEvent {
  final int id;

  const RunSliderEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class SetOnBoardingEvent extends OnboardingEvent {}

class GetOnBoardingEvent extends OnboardingEvent {}
