import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/presentation/pages/dashboard_absence/components/entry_presentation.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';
import 'package:attendance/presentation/widgets/day_tiles.dart';

/// A tapped row's day, opened as a sheet.
///
/// The handoff does not draw this screen — it says to reuse the hero card's
/// `out` layout — so this is that layout, on the same brand gradient, with the
/// day's own date and status instead of today's.
class DayDetailSheet extends StatelessWidget {
  final AttendanceEntry entry;

  const DayDetailSheet({super.key, required this.entry});

  static Future<void> show(BuildContext context, AttendanceEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => DayDetailSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final look = EntryPresentation.of(entry);
    final date = entry.date.toLocal();

    return SafeArea(
      top: false,
      child: ScreenBody(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: T.heroGradient,
              borderRadius: BorderRadius.circular(T.rHero),
              boxShadow: T.heroShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatWeekday(date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formatDate(date),
                            style: AppText.numeric(AppText.heroMetricSmall),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusChip(
                      label: look.label,
                      background: look.badgeBackground,
                      foreground: look.badgeForeground,
                      fontSize: 12.5,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                DayTiles(
                  checkInAt: entry.checkInAt,
                  checkOutAt: entry.checkOutAt,
                  workedMinutes: entry.workedMinutes,
                ),
                if (entry.isLate || entry.overtimeMinutes > 0) ...[
                  const SizedBox(height: 14),
                  Text(
                    [
                      if (entry.isLate)
                        'Terlambat ${entry.lateByMinutes} menit',
                      if (entry.overtimeMinutes > 0)
                        'Lembur ${formatMinutes(entry.overtimeMinutes)}',
                    ].join(' · '),
                    style: AppText.numeric(const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: T.accent500,
                    )),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
