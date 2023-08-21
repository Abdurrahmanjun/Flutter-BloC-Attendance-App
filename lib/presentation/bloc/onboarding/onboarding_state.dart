part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class LoadedSliderState extends OnboardingState {
  final int id;

  const LoadedSliderState({required this.id});

  @override
  List<Object> get props => [id];
}

class ErrorSetOnboardingState extends OnboardingState {}

class LoadedGetOnboardingState extends OnboardingState {}

class ErrorGetOnboardingState extends OnboardingState {}
