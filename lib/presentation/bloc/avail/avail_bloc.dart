import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/common/strings/failures.dart';
import 'package:otaqu/data/models/avail/base_avail.dart';
import 'package:otaqu/domain/usecases/get_avail_use_case.dart';

part 'avail_event.dart';
part 'avail_state.dart';

class AvailBloc extends Bloc<AvailEvent, AvailState> {
  final GetAvailUseCase getAvailUseCase;

  AvailBloc({required this.getAvailUseCase}) : super(AvailInitial()) {
    on<AvailEvent>((event, emit) async {
      if (event is GetAvailEvent) {
        emit(LoadingGetAvailState());

        final either = await getAvailUseCase(
          token: event.token,
          typeId: event.typeId,
        );

        emit(_mapEventAvailFailureOrSuccessToState(either, event.token));
      }
    });
  }
}

AvailState _mapEventAvailFailureOrSuccessToState(
    Either<Failure, BaseAvail> either, String token) {
  return either.fold(
    (failure) => ErrorGetAvailState(
        message: _mapFailureToMessage(failure), token: token),
    (success) => LoadedGetAvailState(result: success),
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
