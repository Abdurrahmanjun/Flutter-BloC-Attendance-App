import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/app_theme.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/presentation/bloc/profile/profile_bloc.dart';
import 'package:attendance/presentation/bloc/report/report_bloc.dart';
import 'package:attendance/presentation/pages/monthly_report/components/arrival_pattern_card.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// Laporan bulanan — the analytics view, reached from the home summary card's
/// "Detail" and from Absensi.
///
/// No single endpoint backs this screen; [ReportBloc] composes it from the
/// month's summary, the previous month's, the month's entries, and the leave
/// balance.
class MonthlyReportPage extends StatelessWidget {
  final DateTime month;

  /// Dismisses the report. The screen is rendered *inside* the Absensi tab
  /// rather than pushed over the shell — the handoff keeps the tab bar visible
  /// here, with Absensi active — so there is no route to pop.
  final VoidCallback onBack;

  const MonthlyReportPage({
    super.key,
    required this.month,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportBloc>(
      create: (_) => di.sl<ReportBloc>()..add(LoadReportEvent(month)),
      child: _ReportView(month: month, onBack: onBack),
    );
  }
}

class _ReportView extends StatelessWidget {
  final DateTime month;
  final VoidCallback onBack;

  const _ReportView({required this.month, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.canvasOverlay,
        child: Scaffold(
          backgroundColor: T.canvas,
          body: SafeArea(
            bottom: false,
            child: BlocBuilder<ReportBloc, ReportState>(
              builder: (context, state) => ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  const SizedBox(height: 14),
                  ScreenBody(child: _BackRow(month: month, onBack: onBack)),
                  const SizedBox(height: T.blockGap),
                  ...switch (state) {
                    ReportLoaded() => _content(context, state),
                    ReportFailure(:final message) => [
                        ScreenBody(
                          child: _Failure(
                            message: message,
                            onRetry: () => context
                                .read<ReportBloc>()
                                .add(LoadReportEvent(month)),
                          ),
                        ),
                      ],
                    _ => const [_Spinner()],
                  },
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, ReportLoaded state) {
    return [
      ScreenBody(child: _HeroStat(state: state)),
      const SizedBox(height: T.blockGap),
      ScreenBody(child: _TwoUp(state: state)),
      const SizedBox(height: T.blockGap),
      ScreenBody(child: ArrivalPatternCard(state: state)),
      const SizedBox(height: T.blockGap),
      ScreenBody(child: _Balances(state: state)),
      const SizedBox(height: T.blockGap),
      const ScreenBody(child: _DownloadButton()),
    ];
  }
}

class _BackRow extends StatelessWidget {
  final DateTime month;
  final VoidCallback onBack;

  const _BackRow({required this.month, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: T.surface,
              borderRadius: BorderRadius.circular(T.rChip),
              border: Border.all(color: T.border),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              size: 22,
              color: T.ink700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Laporan ${formatMonthYear(month).split(' ').first}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.55, // -0.025em
              color: T.ink900,
            ),
          ),
        ),
      ],
    );
  }
}

/// The attendance rate, on brand blue.
class _HeroStat extends StatelessWidget {
  final ReportLoaded state;

  const _HeroStat({required this.state});

  @override
  Widget build(BuildContext context) {
    final rate = state.attendanceRate;
    final delta = state.attendanceDelta;
    final previousMonth = DateTime(state.month.year, state.month.month - 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: T.brand600,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TINGKAT KEHADIRAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.32,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(formatDecimal(rate), style: AppText.bigStat),
                  const SizedBox(width: 3),
                  Padding(
                    // The design offsets the % 4px off the baseline.
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (delta != null)
                    '${delta >= 0 ? 'Naik' : 'Turun'} '
                        '${formatDecimal(delta.abs())}% dari '
                        '${formatMonthYear(previousMonth).split(' ').first}',
                  '${state.summary.present} dari ${state.summary.workingDays} hari',
                ].join(' · '),
                style: AppText.numeric(TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.75),
                )),
              ),
              const SizedBox(height: 16),
              _Track(fraction: (rate / 100).clamp(0.0, 1.0)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Track extends StatelessWidget {
  final double fraction;

  const _Track({required this.fraction});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(T.rPill),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: constraints.maxWidth * fraction,
            decoration: BoxDecoration(
              color: T.accent500,
              borderRadius: BorderRadius.circular(T.rPill),
            ),
          ),
        ),
      ),
    );
  }
}

/// Total hours worked, and the average arrival against the shift.
class _TwoUp extends StatelessWidget {
  final ReportLoaded state;

  const _TwoUp({required this.state});

  @override
  Widget build(BuildContext context) {
    final worked = state.totalWorkedMinutes;
    final overtime = state.summary.overtimeMinutes;

    // IntrinsicHeight, not a bare `stretch`: inside the page's ListView the
    // height is unbounded, and stretching against that forces an infinite
    // constraint. This sizes both cards to the taller one instead.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total jam kerja',
              // Null only when the entry feed failed — saying so beats showing 0.
              value: worked == null ? '—' : formatMinutes(worked),
              footnote:
                  overtime == 0 ? null : '+${formatMinutes(overtime)} lembur',
              footnoteColor: T.success500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, profile) {
                final user = profile is ProfileLoaded ? profile.user : null;
                return _StatCard(
                  label: 'Rata-rata masuk',
                  value: state.summary.averageCheckInTime ?? '—',
                  footnote: user == null ? null : 'Shift ${user.shift.start}',
                  footnoteColor: T.ink400,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? footnote;
  final Color footnoteColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.footnote,
    required this.footnoteColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: T.rRow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: T.ink400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.numeric(const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.42,
              color: T.ink900,
            )),
          ),
          const SizedBox(height: 6),
          Text(
            footnote ?? ' ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.numeric(TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: footnoteColor,
            )),
          ),
        ],
      ),
    );
  }
}

/// Leave used, overtime approved. The design also lists a reimbursement total;
/// the contract has no reimbursement endpoint, so that row is not invented.
class _Balances extends StatelessWidget {
  final ReportLoaded state;

  const _Balances({required this.state});

  @override
  Widget build(BuildContext context) {
    final annual = state.annualLeave;
    final overtime = state.summary.overtimeMinutes;

    final rows = <(String, String)>[
      if (annual != null)
        (
          'Cuti terpakai',
          '${annual.usedDays} / ${annual.entitledDays} hari',
        ),
      ('Lembur disetujui', formatMinutes(overtime)),
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: T.borderSoft),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: T.ink400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rows[i].$2,
                    style: AppText.numeric(const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: T.ink900,
                    )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // TODO(api): no report-export endpoint in the contract yet.
      onTap: () => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Unduh laporan belum tersedia.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(12),
        )),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: T.ink900,
          borderRadius: BorderRadius.circular(T.rButton),
        ),
        child: const Text(
          'Unduh laporan PDF',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
}

class _Failure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Failure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: AppText.body),
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
      ),
    );
  }
}
