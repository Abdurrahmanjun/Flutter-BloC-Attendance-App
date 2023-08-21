import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/common/utils/constants.dart';
import 'package:otaqu/domain/usecases/get_onboarding_use_case.dart';
import 'package:otaqu/domain/usecases/set_onboarding_use_case.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SetOnboardingUseCase setOnboardingUseCase;
  final GetOnboardingUseCase getOnboardingUseCase;

  OnboardingBloc({
    required this.setOnboardingUseCase,
    required this.getOnboardingUseCase,
  }) : super(OnboardingInitial()) {
    on<OnboardingEvent>((event, emit) async {
      if (event is RunSliderEvent) {
        emit(LoadedSliderState(
          id: event.id > promoImagePaths.length - 1 ? 0 : event.id,
        ));
      }

      if (event is SetOnBoardingEvent) {
        await setOnboardingUseCase();
      }

      if (event is GetOnBoardingEvent) {
        final either = await getOnboardingUseCase();
        emit(_mapEventGetOnBoardingFailureOrSuccessToState(either));
      }
    });
  }
}

OnboardingState _mapEventGetOnBoardingFailureOrSuccessToState(
    Either<Failure, String> either) {
  return either.fold(
    (failure) => ErrorGetOnboardingState(),
    (success) => LoadedGetOnboardingState(),
  );
}
