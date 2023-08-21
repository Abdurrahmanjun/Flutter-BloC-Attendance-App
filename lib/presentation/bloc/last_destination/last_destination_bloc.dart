import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/common/strings/failures.dart';
import 'package:otaqu/data/models/destination/destination.dart';
import 'package:otaqu/domain/usecases/get_last_destination_use_case.dart';
import 'package:otaqu/domain/usecases/set_last_destination_use_case.dart';

part 'last_destination_event.dart';
part 'last_destination_state.dart';

class LastDestinationBloc
    extends Bloc<LastDestinationEvent, LastDestinationState> {
  final SetLastDestinationUseCase setLastDestinationUseCase;
  final GetLastDestinationUseCase getLastDestinationUseCase;

  LastDestinationBloc({
    required this.setLastDestinationUseCase,
    required this.getLastDestinationUseCase,
  }) : super(LastDestinationInitial()) {
    on<LastDestinationEvent>((event, emit) async {
      if (event is SetLastDestinationEvent) {
        emit(LoadingSetLastDestinationState());
        final either =
            await setLastDestinationUseCase(destination: event.destination);

        emit(_mapEventSetLastDestinationFailureOrSuccessToState(either));
      }

      if (event is GetLastDestinationEvent) {
        emit(LoadingGetLastDestinationState());
        final either = await getLastDestinationUseCase();

        emit(_mapEventGetLastDestinationFailureOrSuccessToState(either));
      }
    });
  }
}

LastDestinationState _mapEventSetLastDestinationFailureOrSuccessToState(
    Either<Failure, bool> either) {
  return either.fold(
    (failure) =>
        ErrorSetLastDestinationState(message: _mapFailureToMessage(failure)),
    (success) => LoadedSetLastDestinationState(),
  );
}

LastDestinationState _mapEventGetLastDestinationFailureOrSuccessToState(
    Either<Failure, List<Destination>> either) {
  return either.fold(
    (failure) =>
        ErrorGetLastDestinationState(message: _mapFailureToMessage(failure)),
    (success) {
      return LoadedGetLastDestinationState(result: success);
    },
  );
}

String _mapFailureToMessage(Failure failure) {
  switch (failure.runtimeType) {
    case ServerFailure:
      return SERVER_FAILURE_MESSAGE;

    case EmptyCacheFailure:
      return EMPTY_CACHE_FAILURE_MESSAGE;

    case OfflineFailure:
      return OFFLINE_FAILURE_MESSAGE;

    default:
      return "Unexpected Error, Please try again later";
  }
}
