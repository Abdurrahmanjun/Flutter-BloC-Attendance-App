import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';

/// How one day's record reads: its badge label, the colour of its status rail,
/// and the chip colours that go with it.
///
/// Lateness is not a status in the contract — it is a flag on a `present` day —
/// so "Terlambat" and "Hadir" are two presentations of the same status rather
/// than two statuses.
class EntryPresentation {
  final String label;

  /// The 6px rail down the left of the row.
  final Color rail;
  final Color badgeBackground;
  final Color badgeForeground;

  const EntryPresentation({
    required this.label,
    required this.rail,
    required this.badgeBackground,
    required this.badgeForeground,
  });

  factory EntryPresentation.of(AttendanceEntry entry) =>
      switch (entry.status) {
        EntryStatus.present when entry.isLate => const EntryPresentation(
            label: 'Terlambat',
            rail: T.accent500,
            badgeBackground: T.accentTile,
            badgeForeground: T.accentText,
          ),
        EntryStatus.present => const EntryPresentation(
            label: 'Hadir',
            rail: T.success500,
            badgeBackground: T.success50,
            badgeForeground: T.successText,
          ),
        EntryStatus.leave => const EntryPresentation(
            label: 'Cuti',
            rail: T.brand600,
            badgeBackground: T.brand100,
            badgeForeground: T.brand600,
          ),
        EntryStatus.absent => const EntryPresentation(
            label: 'Absen',
            rail: T.danger500,
            badgeBackground: T.danger50,
            badgeForeground: T.dangerText,
          ),
        // Not in the handoff, which only draws the four above — but the
        // contract has it, so it needs somewhere neutral to land.
        EntryStatus.holiday => const EntryPresentation(
            label: 'Libur',
            rail: T.ink300,
            badgeBackground: T.borderSoft,
            badgeForeground: T.ink400,
          ),
      };

  /// The middle line: a punch range, or why there isn't one.
  ///
  /// The handoff writes the leave row as "Cuti tahunan", but the contract
  /// carries no leave type, so this says only what is known.
  static String detailFor(AttendanceEntry entry) {
    final checkIn = entry.checkInAt;
    if (checkIn == null) {
      return switch (entry.status) {
        EntryStatus.leave => 'Cuti',
        EntryStatus.holiday => 'Hari libur',
        _ => 'Tidak ada catatan',
      };
    }

    final checkOut = entry.checkOutAt;
    final end = checkOut == null
        ? 'belum check-out'
        : formatTimeOfDay(checkOut.toLocal());
    return '${formatTimeOfDay(checkIn.toLocal())} — $end';
  }

  /// The trailing total, or an em dash on a day with no hours.
  static String totalFor(AttendanceEntry entry) =>
      entry.workedMinutes == 0 ? '—' : formatMinutes(entry.workedMinutes);
}

/// The chips above the list. `hadir` excludes late days because the rows badge
/// them separately — a chip that contradicted the badge beside it would be
/// worse than the redundancy.
enum HistoryFilter {
  semua('Semua'),
  hadir('Hadir'),
  terlambat('Terlambat'),
  cuti('Cuti'),
  absen('Absen');

  final String label;

  const HistoryFilter(this.label);

  bool matches(AttendanceEntry entry) => switch (this) {
        HistoryFilter.semua => true,
        HistoryFilter.hadir =>
          entry.status == EntryStatus.present && !entry.isLate,
        HistoryFilter.terlambat =>
          entry.status == EntryStatus.present && entry.isLate,
        HistoryFilter.cuti => entry.status == EntryStatus.leave,
        HistoryFilter.absen => entry.status == EntryStatus.absent,
      };
}
