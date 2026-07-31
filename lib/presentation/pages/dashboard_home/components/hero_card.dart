import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';
import 'package:attendance/presentation/bloc/office/office_bloc.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';
import 'package:attendance/presentation/widgets/day_tiles.dart';

/// The four states of the day, as the design names them. Derived from
/// `GET /attendance/today` and the geofence measurement — never held locally.
enum HeroStatus {
  /// Not checked in, inside the fence (or position unknown).
  idle,

  /// Checked in, working.
  working,

  /// Checked out, the day is closed.
  done,

  /// Not checked in and demonstrably outside the fence: check-in is blocked.
  outside,
}

/// The home screen's single most important element: where you stand today, and
/// the one action that follows from it.
///
/// The card's height must not jump between states, so a load renders a skeleton
/// in the same geometry rather than a spinner, and a failed punch keeps the
/// previous state and puts its message in the sub slot instead of a toast.
class HeroCard extends StatefulWidget {
  const HeroCard({super.key});

  @override
  State<HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<HeroCard> {
  /// The last day the server gave us. `TodayBloc` re-reads after every punch,
  /// so it passes through states that carry no day at all; holding the last one
  /// is what keeps the card from collapsing to a skeleton mid-punch.
  TodayAttendance? _day;
  bool _punching = false;

  /// A rejected punch. Shown inline in the sub slot, in amber — the design
  /// explicitly does not want a toast for this.
  String? _error;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodayBloc, TodayState>(
      listener: (context, state) {
        switch (state) {
          case TodayLoaded(:final today, :final punching):
            setState(() {
              _day = today;
              _punching = punching;
              // A new attempt clears the last one's complaint.
              if (punching) _error = null;
            });
          case TodayPunchRejected(:final message):
            setState(() {
              _punching = false;
              _error = message;
            });
          case TodayPunchAccepted(:final message):
            setState(() {
              _punching = false;
              _error = null;
            });
            // The server's confirmation ("Checked in at 09:03. You are 3
            // minutes late.") exists nowhere else in the response. Only
            // *failures* were moved inline; a success still confirms itself.
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(message),
                backgroundColor: T.success500,
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(12),
              ));
          default:
            break;
        }
      },
      builder: (context, todayState) {
        return BlocBuilder<OfficeBloc, OfficeState>(
          builder: (context, officeState) =>
              _Shell(child: _body(context, todayState, officeState)),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    TodayState todayState,
    OfficeState officeState,
  ) {
    final day = _day;
    if (day == null) {
      if (todayState is TodayLoadFailure) {
        return _Failure(
          message: todayState.message,
          onRetry: () => context.read<TodayBloc>().add(LoadTodayEvent()),
        );
      }
      return const _Skeleton();
    }

    final proximity = officeState is OfficeProximityKnown ? officeState : null;

    // Only a `not_checked_in` day can be blocked by the fence — you are always
    // allowed to check *out*, wherever you have wandered off to.
    final status = switch (day.status) {
      TodayStatus.checkedOut => HeroStatus.done,
      TodayStatus.checkedIn => HeroStatus.working,
      TodayStatus.notCheckedIn
          when proximity != null && !proximity.withinGeofence =>
        HeroStatus.outside,
      TodayStatus.notCheckedIn => HeroStatus.idle,
    };

    return _Content(
      today: day,
      status: status,
      punching: _punching,
      proximity: proximity,
      error: _error,
    );
  }
}

/// The gradient shell. Every state renders inside this, unchanged.
class _Shell extends StatelessWidget {
  final Widget child;

  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: T.riseIn,
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: T.heroGradient,
          borderRadius: BorderRadius.circular(T.rHero),
          boxShadow: T.heroShadow,
        ),
        child: child,
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final TodayAttendance today;
  final HeroStatus status;
  final bool punching;
  final OfficeProximityKnown? proximity;
  final String? error;

  const _Content({
    required this.today,
    required this.status,
    required this.punching,
    required this.proximity,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _metricColumn()),
            const SizedBox(width: 12),
            _statusColumn(),
          ],
        ),
        ..._insert(),
        const SizedBox(height: 20),
        _ctaRow(context),
      ],
    );
  }

  // ------------------------------------------------------------- left column --

  Widget _metricColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _kicker,
          style: AppText.numeric(TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2, // 0.1em
            color: Colors.white.withOpacity(0.6),
          )),
        ),
        const SizedBox(height: 8),
        Text(
          _metric,
          maxLines: 1,
          overflow: TextOverflow.visible,
          softWrap: false,
          style: _hasDuration ? AppText.heroMetric : AppText.heroMetricSmall,
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 210),
          child: Text(
            error ?? _sub,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: error != null ? T.accent500 : Colors.white.withOpacity(0.78),
            ),
          ),
        ),
      ],
    );
  }

  bool get _hasDuration =>
      status == HeroStatus.working || status == HeroStatus.done;

  String get _kicker => switch (status) {
        HeroStatus.working => today.checkInAt == null
            ? 'Sedang bekerja'
            : 'Masuk ${formatTimeOfDay(today.checkInAt!.toLocal())}'
                '${today.isLate ? ' · terlambat ${today.lateByMinutes} menit' : ''}',
        HeroStatus.done => 'Hari ini selesai',
        _ => 'Hari ini · ${formatDayMonthFull(today.date.toLocal())}',
      };

  String get _metric =>
      _hasDuration ? formatMinutes(today.workedMinutes) : 'Belum absen';

  String get _sub => switch (status) {
        HeroStatus.idle => 'Shift kamu mulai ${today.shift.start}. '
            'Check-in saat sudah di kantor.',
        HeroStatus.working =>
          'Sudah bekerja hari ini. Check-out otomatis diingatkan '
              '${today.shift.end}.',
        HeroStatus.done => today.isLate
            ? 'Terlambat ${today.lateByMinutes} menit — tercatat di laporan bulanan.'
            : 'Tepat waktu — tercatat di laporan bulanan.',
        HeroStatus.outside => 'Kamu berada di luar area kantor.',
      };

  // ------------------------------------------------------------ right column --

  Widget _statusColumn() {
    final (label, background, foreground) = switch (status) {
      HeroStatus.idle => (
          'Menunggu',
          Colors.white.withOpacity(0.16),
          Colors.white
        ),
      HeroStatus.working => ('Bekerja', T.accent500, T.accentOnFill),
      HeroStatus.done => (
          'Selesai',
          Colors.white.withOpacity(0.16),
          Colors.white
        ),
      HeroStatus.outside => (
          'Di luar area',
          T.accent500.withOpacity(0.22),
          T.accent500
        ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(T.rPill),
            border: Border.all(color: Colors.white.withOpacity(0.16)),
          ),
          child: Text(
            '${today.shift.start} – ${today.shift.end}',
            style: AppText.numeric(const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
          ),
        ),
        const SizedBox(height: 8),
        StatusChip(
          label: label,
          background: background,
          foreground: foreground,
          fontSize: 12.5,
        ),
      ],
    );
  }

  // ------------------------------------------------------ state-specific slot --

  List<Widget> _insert() => switch (status) {
        HeroStatus.working => [
            const SizedBox(height: 18),
            _ShiftProgress(today: today),
          ],
        HeroStatus.done => [
            const SizedBox(height: 18),
            DayTiles(
              checkInAt: today.checkInAt,
              checkOutAt: today.checkOutAt,
              workedMinutes: today.workedMinutes,
            ),
          ],
        HeroStatus.outside when proximity != null => [
            const SizedBox(height: 18),
            _GeofenceBlock(proximity: proximity!),
          ],
        _ => const [],
      };

  // ----------------------------------------------------------------- the CTA --

  Widget _ctaRow(BuildContext context) {
    final blocked = status == HeroStatus.outside;

    final (label, onTap) = switch (status) {
      HeroStatus.idle => (
          'Check in sekarang',
          () => context.read<TodayBloc>().add(CheckInEvent())
        ),
      HeroStatus.working => (
          'Check out',
          () => context.read<TodayBloc>().add(CheckOutEvent())
        ),
      HeroStatus.done => ('Lihat ringkasan hari ini', null),
      HeroStatus.outside => ('Check in', null),
    };

    return Row(
      children: [
        Expanded(
          child: _HeroButton(
            label: label,
            busy: punching,
            disabled: blocked,
            onTap: onTap,
          ),
        ),
        if (blocked) ...[
          const SizedBox(width: 10),
          _OutlineButton(
            label: 'Ajukan izin',
            // TODO(api): no out-of-office request endpoint exists yet.
            onTap: () => _notYetAvailable(context, 'Izin absen luar kantor'),
          ),
        ],
      ],
    );
  }
}

void _notYetAvailable(BuildContext context, String what) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text('$what belum tersedia.'),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(12),
    ));
}

/// White fill, brand text — the primary action on the blue card.
class _HeroButton extends StatelessWidget {
  final String label;
  final bool busy;
  final bool disabled;
  final VoidCallback? onTap;

  const _HeroButton({
    required this.label,
    required this.busy,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inert = busy || disabled || onTap == null;

    return GestureDetector(
      onTap: inert ? null : onTap,
      child: Container(
        height: 51, // 16px padding + 19px line, fixed so busy does not resize it
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled ? Colors.white.withOpacity(0.14) : Colors.white,
          borderRadius: BorderRadius.circular(T.rInput),
          boxShadow: disabled ? null : T.ctaShadow,
        ),
        child: busy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(T.brand600),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: disabled
                      ? Colors.white.withOpacity(0.45)
                      : T.brand600,
                ),
              ),
      ),
    );
  }
}

/// The outline secondary that only appears alongside a blocked check-in.
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 51,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(T.rInput),
          border: Border.all(color: Colors.white.withOpacity(0.28), width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// `working` — how far through the shift you are.
class _ShiftProgress extends StatelessWidget {
  final TodayAttendance today;

  const _ShiftProgress({required this.today});

  /// `HH:mm` to minutes past midnight, or null if it is not in that shape.
  static int? _minutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    return (h == null || m == null) ? null : h * 60 + m;
  }

  @override
  Widget build(BuildContext context) {
    final start = _minutes(today.shift.start);
    final end = _minutes(today.shift.end);
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    // An overnight shift wraps past midnight; treat the end as the next day.
    final total = (start == null || end == null)
        ? null
        : (end > start ? end - start : end + 1440 - start);
    final elapsed = (start == null || total == null)
        ? null
        : (nowMinutes >= start ? nowMinutes - start : nowMinutes + 1440 - start);

    final fraction = (total == null || total == 0 || elapsed == null)
        ? 0.0
        : (elapsed / total).clamp(0.0, 1.0);

    return Column(
      children: [
        _Track(fraction: fraction, height: 8, fill: T.accent500),
        const SizedBox(height: 8),
        Row(
          children: [
            _progressLabel(today.shift.start, TextAlign.left),
            _progressLabel(
              '${formatTimeOfDay(now)} sekarang',
              TextAlign.center,
            ),
            _progressLabel(today.shift.end, TextAlign.right),
          ],
        ),
      ],
    );
  }

  Widget _progressLabel(String text, TextAlign align) => Expanded(
        child: Text(
          text,
          textAlign: align,
          style: AppText.numeric(TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
          )),
        ),
      );
}

/// `outside` — how far away you are, and how much closer you have to get.
class _GeofenceBlock extends StatelessWidget {
  final OfficeProximityKnown proximity;

  const _GeofenceBlock({required this.proximity});

  /// The distance at which the meter reads empty. The handoff specifies the
  /// fill as `1 - clamp(distance / outer)` but pins `outer` only through one
  /// mock frame (22% at 19.8 km). Anchoring it to the office's own radius keeps
  /// the requirement that actually matters — that walking toward the office
  /// visibly fills the bar — which a 25 km scale would not.
  static const _outerRadiusMultiple = 10;

  @override
  Widget build(BuildContext context) {
    final office = proximity.office;
    final outer = (office.radiusMeters * _outerRadiusMultiple).toDouble();
    final fraction =
        (1 - (proximity.distanceMeters / outer)).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(T.rButton),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_rounded, size: 17, color: T.accent500),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${formatDistance(proximity.distanceMeters)} dari '
                  '${office.name}',
                  style: AppText.numeric(const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _Track(
            fraction: fraction,
            height: 6,
            fill: T.accent500,
            knob: true,
          ),
          const SizedBox(height: 11),
          Text(
            'Check-in aktif dalam radius ${office.radiusMeters} m dari kantor. '
            'Mendekat, atau ajukan izin absen luar kantor.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// A translucent track with a coloured fill, optionally with a knob at the
/// fill's leading edge. Shared by the shift progress and the distance meter.
class _Track extends StatelessWidget {
  final double fraction;
  final double height;
  final Color fill;
  final bool knob;

  const _Track({
    required this.fraction,
    required this.height,
    required this.fill,
    this.knob = false,
  });

  @override
  Widget build(BuildContext context) {
    const knobSize = 14.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SizedBox(
          height: knob ? knobSize : height,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(T.rPill),
                ),
              ),
              // The distance meter is live, so animate rather than snap.
              AnimatedContainer(
                duration: T.stateChange,
                curve: Curves.easeOut,
                height: height,
                width: width * fraction,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(T.rPill),
                ),
              ),
              if (knob)
                AnimatedPositioned(
                  duration: T.stateChange,
                  curve: Curves.easeOut,
                  left: (width * fraction - knobSize / 2)
                      .clamp(0.0, width - knobSize),
                  child: Container(
                    width: knobSize,
                    height: knobSize,
                    decoration: BoxDecoration(
                      color: fill,
                      shape: BoxShape.circle,
                      border: Border.all(color: T.brand700, width: 3),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The load state. Same geometry as a real card, so nothing shifts when the
/// day arrives — the design asks for a skeleton here, not a spinner.
class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(6),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(110, 12),
                  const SizedBox(height: 10),
                  bar(150, 30),
                  const SizedBox(height: 10),
                  bar(190, 14),
                  const SizedBox(height: 6),
                  bar(140, 14),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                bar(104, 30),
                const SizedBox(height: 8),
                bar(74, 25),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        bar(double.infinity, 51),
      ],
    );
  }
}

/// `GET /attendance/today` itself failed — there is no day to render.
class _Failure extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Failure({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tidak bisa memuat hari ini',
          style: AppText.heroMetricSmall.copyWith(fontSize: 19),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.78),
          ),
        ),
        const SizedBox(height: 20),
        _HeroButton(
          label: 'Coba lagi',
          busy: false,
          disabled: false,
          onTap: onRetry,
        ),
      ],
    );
  }
}
