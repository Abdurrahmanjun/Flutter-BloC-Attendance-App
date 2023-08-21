import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/common/strings/failures.dart';
import 'package:otaqu/domain/usecases/get_token_use_case.dart';
import 'package:otaqu/domain/usecases/set_token_use_case.dart';

part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final SetTokenUseCase setTokenUseCase;
  final GetTokenUseCase getTokenUseCase;

  TokenBloc({
    required this.setTokenUseCase,
    required this.getTokenUseCase,
  }) : super(TokenInitial()) {
    on<TokenEvent>((event, emit) async {
      if (event is SetTokenEvent) {
        emit(LoadingGetTokenState());

        final either = await setTokenUseCase(
          username: event.username,
          password: event.password,
        );

        emit(_mapEventGetTokenFailureOrSuccessToState(either));
      }

      if (event is GetTokenEvent) {
        emit(LoadingGetTokenState());

        final either = await getTokenUseCase();
        emit(_mapEventGetTokenFailureOrSuccessToState(either));
      }
    });
  }

  TokenState _mapEventGetTokenFailureOrSuccessToState(
      Either<Failure, String> either) {
    return either.fold(
      (failure) => ErrorGetTokenState(message: _mapFailureToMessage(failure)),
      (success) {
        return LoadedGetTokenState(token: success);
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
}
