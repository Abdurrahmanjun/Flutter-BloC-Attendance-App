import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/common/strings/failures.dart';
import 'package:otaqu/data/models/destination/destination.dart';
import 'package:otaqu/domain/usecases/get_destination_use_case.dart';
import 'package:otaqu/domain/usecases/set_destination_use_case.dart';

part 'destination_event.dart';
part 'destination_state.dart';

class DestinationBloc extends Bloc<DestinationEvent, DestinationState> {
  final SetDestinationUseCase setDestinationUseCase;
  final GetDestinationUseCase getDestinationUseCase;

  DestinationBloc({
    required this.setDestinationUseCase,
    required this.getDestinationUseCase,
  }) : super(DestinationInitial()) {
    on<DestinationEvent>((event, emit) async {
      if (event is SetDestinationEvent) {
        emit(LoadingSetDestinationState());

        final either = await setDestinationUseCase(event.token);
        emit(_mapEventDestinationFailureOrSuccessToState(either, event.token));
      }

      if (event is GetDestinationEvent) {
        emit(LoadingSetDestinationState());

        final either = await getDestinationUseCase();

        emit(_mapEventDestinationFailureOrSuccessToState(either, event.token));
      }

      if (event is SearchEvent) {
        emit(LoadingSearchState());

        var tempt = List.of(event.data);
        var result = List.of(event.data);

        if (event.key.isEmpty) {
          emit(LoadedSearchState(
            result: const [],
            oldData: tempt,
            token: event.token,
          ));
        } else {
          result = tempt.where((element) {
            final name = element.name!.toLowerCase();
            final searchLower = event.key.toLowerCase();
            final containts = name.contains(searchLower);

            return containts;
          }).toList();

          emit(LoadedSearchState(
            result: result,
            oldData: tempt,
            token: event.token,
          ));
        }
      }
    });
  }

  DestinationState _mapEventDestinationFailureOrSuccessToState(
      Either<Failure, List<Destination>> either, String token) {
    return either.fold(
      (failure) => ErrorGetDestinationState(
          message: _mapFailureToMessage(failure), token: token),
      (success) => LoadedGetDestinationState(
        result: success,
        token: token,
      ),
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
}
