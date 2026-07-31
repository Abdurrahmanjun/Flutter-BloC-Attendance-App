part of 'profile_detail_bloc.dart';

abstract class ProfileDetailState extends Equatable {
  const ProfileDetailState();

  @override
  List<Object?> get props => [];
}

class ProfileDetailInitial extends ProfileDetailState {}

class ProfileDetailLoading extends ProfileDetailState {}

class ProfileDetailFailure extends ProfileDetailState {
  final String message;

  const ProfileDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileDetailLoaded extends ProfileDetailState {
  final User user;

  /// Empty when the balance call failed; "Sisa cuti" then reads as unknown
  /// rather than as zero, which would be a very different claim.
  final List<LeaveBalance> balances;

  final List<Office> offices;

  /// Null when the month's summary failed.
  final MonthlySummary? summary;

  const ProfileDetailLoaded({
    required this.user,
    required this.balances,
    required this.offices,
    required this.summary,
  });

  /// Years of service to one decimal, from `joinedAt`. Null when the contract
  /// omitted the field — it is not in its `required` list.
  double? get yearsOfService {
    final joined = user.joinedAt;
    if (joined == null) return null;
    final days = DateTime.now().difference(joined.toLocal()).inDays;
    return days <= 0 ? 0 : days / 365.25;
  }

  /// Remaining annual leave, or null if the balance is unknown.
  int? get remainingLeaveDays => balances.annual?.remainingDays;

  /// This month's attendance rate, or null if the summary is unknown.
  double? get attendanceRate {
    final value = summary;
    if (value == null || value.workingDays == 0) return null;
    return value.present / value.workingDays * 100;
  }

  /// The user's assigned office, matched by id against the geofence list.
  Office? get office {
    final id = user.officeId;
    if (id == null) return null;
    for (final office in offices) {
      if (office.id == id) return office;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        user.id,
        user.name,
        balances.length,
        offices.length,
        summary?.month,
      ];
}
