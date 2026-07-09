import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/data/models/reference/announcement.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';

part 'announcement_event.dart';
part 'announcement_state.dart';

/// `GET /api/announcements`, replacing the bundled `promoImagePaths` assets.
class AnnouncementBloc extends Bloc<AnnouncementEvent, AnnouncementState> {
  final GetAnnouncementsUseCase getAnnouncementsUseCase;

  AnnouncementBloc({required this.getAnnouncementsUseCase})
      : super(AnnouncementInitial()) {
    on<LoadAnnouncementsEvent>((event, emit) async {
      emit(AnnouncementLoading());
      final either = await getAnnouncementsUseCase();
      emit(either.fold(
        (failure) => AnnouncementFailure(failure.message),
        (announcements) => AnnouncementLoaded(announcements),
      ));
    });
  }
}
