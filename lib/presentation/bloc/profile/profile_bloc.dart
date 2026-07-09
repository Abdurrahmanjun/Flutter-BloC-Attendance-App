import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/user/user.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// `GET /api/me`.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetMeUseCase getMeUseCase;

  ProfileBloc({required this.getMeUseCase}) : super(ProfileInitial()) {
    on<LoadProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      final either = await getMeUseCase();
      emit(either.fold(
        (failure) => ProfileFailure(failure.message),
        (user) => ProfileLoaded(user),
      ));
    });
  }
}
