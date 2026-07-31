import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/presentation/bloc/attendance/history_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/summary_bloc.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// `GET /api/attendance/summary?month=YYYY-MM`, rendered as the design's
/// month-at-a-glance card. Replaces the old ring-and-legend diagram.
///
/// `late` is a subset of `present`, so the tiles show on-time and late as a
/// split of present rather than as siblings — adding present + late + absent +
/// leave would overcount, which is the mistake the contract warns about.
class MonthlySummaryCard extends StatelessWidget {
  final VoidCallback onDetail;

  const MonthlySummaryCard({super.key, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) => AppCard(
        child: switch (state) {
          SummaryLoaded(:final summary) =>
            _Content(summary: summary, onDetail: onDetail),
          SummaryFailure(:final message) => _Failure(
              message: message,
              onRetry: () => context
                  .read<SummaryBloc>()
                  .add(LoadSummaryEvent(SummaryBloc.currentMonth())),
            ),
          _ => const _Skeleton(),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final MonthlySummary summary;
  final VoidCallback onDetail;

  const _Content({required this.summary, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: formatMonthKey(summary.month),
          subtitle: '${summary.workingDays} hari kerja',
          actionLabel: 'Detail',
          onAction: onDetail,
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: '${summary.onTime}',
                label: 'Tepat waktu',
                background: T.successTile,
                valueColor: T.successText,
                labelColor: T.successTileLabel,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                value: '${summary.late}',
                label: 'Terlambat',
                background: T.accentTile,
                valueColor: T.accentText,
                labelColor: T.accentTileLabel,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                value: '${summary.absent}',
                label: 'Absen',
                background: T.danger50,
                valueColor: T.dangerText,
                labelColor: T.dangerTileLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        const WeekStrip(),
      ],
    );
  }
}

/// The seven-bar week strip. Derived from the history feed rather than served —
/// `/attendance/summary` is month-level only, so this reads whatever days
/// `HistoryBloc` has already loaded and renders the current week from them.
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key});

  static const _height = 44.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        final now = DateTime.now();
        final monday = DateUtils.dateOnly(now)
            .subtract(Duration(days: now.weekday - 1));

        final byDay = <DateTime, AttendanceEntry>{
          if (state is HistoryLoaded)
            for (final entry in state.entries)
              DateUtils.dateOnly(entry.date.toLocal()): entry,
        };

        final days = List.generate(7, (i) => monday.add(Duration(days: i)));
        final worked = [
          for (final day in days) byDay[day]?.workedMinutes ?? 0,
        ];
        final peak = worked.fold<int>(0, (a, b) => a > b ? a : b);

        return SizedBox(
          height: _height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 7; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _Bar(
                    // A day with nothing on it still shows a stub, so the
                    // strip reads as seven days rather than four.
                    fraction: peak == 0 ? 0.3 : (worked[i] / peak).clamp(0.3, 1.0),
                    color: _colorFor(days[i], byDay[days[i]], now),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static Color _colorFor(DateTime day, AttendanceEntry? entry, DateTime now) {
    if (DateUtils.isSameDay(day, now)) return T.brand600;
    if (entry?.isLate ?? false) return T.accent500;
    if (entry == null || entry.workedMinutes == 0) return T.barMuted;
    return T.brand200;
  }
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
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget block(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: T.borderSoft,
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            block(96, 15),
            const Spacer(),
            block(44, 13),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: block(double.infinity, 62)),
            ],
          ],
        ),
        const SizedBox(height: 15),
        block(double.infinity, WeekStrip._height),
      ],
    );
  }
}

class _Failure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Failure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: AppText.body),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onRetry,
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Text('Coba lagi', style: AppText.sectionAction),
          ),
        ),
      ],
    );
  }
}
