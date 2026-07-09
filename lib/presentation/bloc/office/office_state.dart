part of 'office_bloc.dart';

abstract class OfficeState extends Equatable {
  const OfficeState();

  @override
  List<Object?> get props => [];
}

/// Nothing known yet. The check-in button stays enabled.
class OfficeInitial extends OfficeState {}

class OfficeProximityKnown extends OfficeState {
  final Office office;
  final double distanceMeters;
  final bool withinGeofence;

  const OfficeProximityKnown({
    required this.office,
    required this.distanceMeters,
    required this.withinGeofence,
  });

  @override
  List<Object?> get props => [office.id, distanceMeters, withinGeofence];
}
