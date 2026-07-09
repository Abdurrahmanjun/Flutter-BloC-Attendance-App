import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/domain/usecases/get_token_use_case.dart';
import 'package:attendance/domain/usecases/logout_use_case.dart';
import 'package:attendance/domain/usecases/set_token_use_case.dart';

part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final SetTokenUseCase setTokenUseCase;
  final GetTokenUseCase getTokenUseCase;
  final LogoutUseCase logoutUseCase;

  TokenBloc({
    required this.setTokenUseCase,
    required this.getTokenUseCase,
    required this.logoutUseCase,
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

      if (event is LogoutEvent) {
        await logoutUseCase();
        emit(LoggedOutState());
      }
    });
  }

  TokenState _mapEventGetTokenFailureOrSuccessToState(
      Either<Failure, String> either) {
    return either.fold(
      // Every Failure carries a renderable message; for API errors it is the
      // envelope's `message` verbatim.
      (failure) => ErrorGetTokenState(message: failure.message),
      (success) {
        return LoadedGetTokenState(token: success);
      },
    );
  }
}
