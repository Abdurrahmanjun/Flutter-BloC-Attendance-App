import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/presentation/bloc/report/report_bloc.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// "Pola kedatangan" — punctuality by weekday, Monday to Friday.
///
/// Bar height is the share of that weekday's attended days that were on time,
/// which is what makes the insight line underneath ("Kamis paling sering
/// terlambat") a reading of the chart rather than a separate claim.
class ArrivalPatternCard extends StatelessWidget {
  final ReportLoaded state;

  const ArrivalPatternCard({super.key, required this.state});

  static const _chartHeight = 110.0;

  /// Short weekday labels, indexed by `DateTime.weekday`.
  static const _labels = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum'];

  @override
  Widget build(BuildContext context) {
    final pattern = state.arrivalPattern;
    final worst = state.worstArrivalDay;
    final today = DateTime.now().weekday;
    final hasData = pattern.any((day) => day.present > 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pola kedatangan', style: AppText.sectionHeader),
          const SizedBox(height: 16),
          if (!hasData)
            const SizedBox(
              height: _chartHeight,
              child: Center(
                child: Text(
                  'Belum ada kedatangan tercatat bulan ini.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: T.ink300,
                  ),
                ),
              ),
            )
          else ...[
            SizedBox(
              height: _chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final day in pattern) ...[
                    if (day.weekday != DateTime.monday)
                      const SizedBox(width: 10),
                    Expanded(
                      child: _Bar(
                        // A weekday with no record still shows a stub so the
                        // chart reads as five days, not three.
                        fraction:
                            day.present == 0 ? 0.12 : day.punctuality.clamp(0.15, 1.0),
                        color: switch (day) {
                          _ when day.weekday == worst?.weekday => T.accent500,
                          _ when day.weekday == today => T.brand600,
                          _ => T.brand200,
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                for (final day in pattern) ...[
                  if (day.weekday != DateTime.monday) const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _labels[day.weekday],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: T.ink300,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 14),
          Text(_insight(worst), style: AppText.numeric(AppText.body)),
        ],
      ),
    );
  }

  String _insight(ArrivalDay? worst) {
    if (worst == null) {
      return 'Tidak ada keterlambatan bulan ini — kedatangan kamu konsisten '
          'tepat waktu.';
    }
    final weekday = _weekdayName(worst.weekday);
    final total = state.chartedLateDays;
    return '$weekday paling sering terlambat — ${worst.late} dari $total '
        'keterlambatan bulan ini.';
  }

  static String _weekdayName(int weekday) =>
      formatWeekday(DateTime(2024, 1, weekday));
}

class _Bar extends StatelessWidget {
  final double fraction;
  final Color color;

  const _Bar({required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: fraction,
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
