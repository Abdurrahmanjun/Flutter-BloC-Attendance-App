import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:attendance/common/location/location_service.dart';
import 'package:attendance/data/models/reference/office.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';

part 'office_event.dart';
part 'office_state.dart';

/// `GET /api/office/locations` plus the device's own position, so the UI can
/// grey out check-in when the user is obviously too far away and show how far
/// they still have to walk.
///
/// This is a **UX affordance, not an authorisation check**. The server
/// re-validates every punch and is the authority; if this bloc cannot get a fix
/// or the request fails, the button stays enabled and the server decides.
class OfficeBloc extends Bloc<OfficeEvent, OfficeState> {
  final GetOfficesUseCase getOfficesUseCase;
  final LocationService locationService;

  /// How often the home screen re-measures while it is on screen. The design's
  /// distance meter is meant to move as you approach, which a single fix taken
  /// at page load cannot do.
  static const pollInterval = Duration(seconds: 15);

  Timer? _poll;

  /// Cached so a re-measure costs one location fix, not a round trip as well.
  List<Office>? _offices;

  OfficeBloc({
    required this.getOfficesUseCase,
    required this.locationService,
  }) : super(OfficeInitial()) {
    on<CheckProximityEvent>(_onCheck);
    on<WatchProximityEvent>(_onWatch);
    on<StopWatchingProximityEvent>(_onStopWatching);
  }

  Future<void> _onWatch(
    WatchProximityEvent event,
    Emitter<OfficeState> emit,
  ) async {
    _poll?.cancel();
    _poll = Timer.periodic(pollInterval, (_) => add(CheckProximityEvent()));
    await _onCheck(CheckProximityEvent(), emit);
  }

  void _onStopWatching(
    StopWatchingProximityEvent event,
    Emitter<OfficeState> emit,
  ) {
    _poll?.cancel();
    _poll = null;
  }

  Future<void> _onCheck(
    CheckProximityEvent event,
    Emitter<OfficeState> emit,
  ) async {
    List<Office> offices;
    if (_offices != null) {
      offices = _offices!;
    } else {
      final either = await getOfficesUseCase();
      offices = either.fold((failure) => <Office>[], (list) => list);
      _offices = offices;
    }

    if (offices.isEmpty) {
      // Unknown: leave the button enabled, say nothing, and let the next tick
      // retry the lookup rather than caching the empty result forever.
      _offices = null;
      return;
    }

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
  }

  @override
  Future<void> close() {
    _poll?.cancel();
    return super.close();
  }
}
