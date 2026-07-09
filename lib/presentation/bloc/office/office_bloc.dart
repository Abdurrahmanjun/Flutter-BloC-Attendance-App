import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/common/location/location_service.dart';
import 'package:attendance/data/models/reference/office.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';

part 'office_event.dart';
part 'office_state.dart';

/// `GET /api/office/locations` plus the device's own position, purely so the
/// UI can grey out the check-in button when the user is obviously too far away.
///
/// This is a **UX affordance, not an authorisation check**. The server
/// re-validates every punch and is the authority; if this bloc cannot get a fix
/// or the request fails, the button stays enabled and the server decides.
class OfficeBloc extends Bloc<OfficeEvent, OfficeState> {
  final GetOfficesUseCase getOfficesUseCase;
  final LocationService locationService;

  OfficeBloc({
    required this.getOfficesUseCase,
    required this.locationService,
  }) : super(OfficeInitial()) {
    on<CheckProximityEvent>((event, emit) async {
      final either = await getOfficesUseCase();

      final offices = either.fold((failure) => <Office>[], (list) => list);
      if (offices.isEmpty) return; // Unknown: leave the button enabled.

      try {
        final position = await locationService.currentPosition();

        Office? nearest;
        var nearestDistance = double.infinity;
        for (final office in offices) {
          final distance = locationService.distanceBetween(
            position.latitude,
            position.longitude,
            office.lat,
            office.lng,
          );
          if (distance < nearestDistance) {
            nearestDistance = distance;
            nearest = office;
          }
        }

        emit(OfficeProximityKnown(
          office: nearest!,
          distanceMeters: nearestDistance,
          withinGeofence: nearestDistance <= nearest.radiusMeters,
        ));
      } on LocationException {
        // No fix. Say nothing and let the server decide.
      }
    });
  }
}
