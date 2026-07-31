part of 'report_bloc.dart';

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportFailure extends ReportState {
  final String message;

  const ReportFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// One weekday's arrival record, for the "Pola kedatangan" chart.
class ArrivalDay {
  /// `DateTime.weekday`, 1 = Monday.
  final int weekday;
  final int present;
  final int late;

  const ArrivalDay({
    required this.weekday,
    required this.present,
    required this.late,
  });

  int get onTime => present - late;

  /// Share of that weekday's attended days that were on time. A weekday with
  /// no record at all reads as 0 rather than dividing by zero.
  double get punctuality => present == 0 ? 0 : onTime / present;
}

class ReportLoaded extends ReportState {
  final DateTime month;
  final MonthlySummary summary;

  /// Null when the previous month could not be read — the delta is then hidden
  /// rather than guessed.
  final MonthlySummary? previousSummary;

  /// The month's entries. Empty if the feed failed; every figure derived from
  /// it degrades to null rather than to a wrong number.
  final List<AttendanceEntry> entries;

  final List<LeaveBalance> balances;

  const ReportLoaded({
    required this.month,
    required this.summary,
    required this.previousSummary,
    required this.entries,
    required this.balances,
  });

  /// Attendance rate as a percentage. `present` includes late days — a late
  /// day is still a day you showed up.
  double get attendanceRate =>
      summary.workingDays == 0 ? 0 : summary.present / summary.workingDays * 100;

  /// Percentage points against last month, or null when there is no last month.
  double? get attendanceDelta {
    final previous = previousSummary;
    if (previous == null || previous.workingDays == 0) return null;
    return attendanceRate - (previous.present / previous.workingDays * 100);
  }

  /// Summed from the entries, because `/attendance/summary` does not carry it.
  /// Null when the feed failed, so the card can say so instead of showing 0.
  int? get totalWorkedMinutes => entries.isEmpty
      ? null
      : entries.fold<int>(0, (total, entry) => total + entry.workedMinutes);

  /// Monday–Friday, in order. Weekends are not part of the pattern the design
  /// charts.
  List<ArrivalDay> get arrivalPattern {
    return [
      for (var weekday = DateTime.monday; weekday <= DateTime.friday; weekday++)
        () {
          final days = entries.where((entry) =>
              entry.date.toLocal().weekday == weekday &&
              entry.status == EntryStatus.present);
          return ArrivalDay(
            weekday: weekday,
            present: days.length,
            late: days.where((entry) => entry.isLate).length,
          );
        }(),
    ];
  }

  /// The weekday with the most late arrivals, for the amber bar and the insight
  /// line. Null when nothing was late — there is no story to tell.
  ArrivalDay? get worstArrivalDay {
    ArrivalDay? worst;
    for (final day in arrivalPattern) {
      if (day.late == 0) continue;
      if (worst == null || day.late > worst.late) worst = day;
    }
    return worst;
  }

  /// Total late arrivals across the charted weekdays, so the insight can say
  /// "2 of 3" without contradicting the chart it sits under.
  int get chartedLateDays =>
      arrivalPattern.fold<int>(0, (total, day) => total + day.late);

  LeaveBalance? get annualLeave => balances.annual;

  @override
  List<Object?> get props => [
        month,
        summary.month,
        summary.present,
        previousSummary?.month,
        entries.length,
        balances.length,
      ];
}
