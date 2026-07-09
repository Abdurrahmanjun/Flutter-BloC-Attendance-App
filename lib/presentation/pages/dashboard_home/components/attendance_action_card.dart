import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/today_attendance.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';

/// The home screen's main action, driven entirely by `GET /attendance/today`:
/// `not_checked_in` offers Check In, `checked_in` offers Check Out, and
/// `checked_out` shows the day's summary instead of a button.
class AttendanceActionCard extends StatelessWidget {
  const AttendanceActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TodayBloc, TodayState>(
      listenWhen: (_, state) =>
          state is TodayPunchAccepted || state is TodayPunchRejected,
      listener: (context, state) {
        // The server's `message` is guaranteed renderable, and for a geofence
        // rejection it is the only place the measured distance appears.
        final (message, color) = switch (state) {
          TodayPunchAccepted(:final message) => (message, infoGreen),
          TodayPunchRejected(:final message) => (message, infoRed),
          _ => (null, null),
        };
        if (message == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(8),
            duration: const Duration(seconds: 4),
          ));
      },
      // The transient punch states carry no `today`, so keep rendering the last
      // loaded day rather than flashing a spinner over the whole card.
      buildWhen: (_, state) =>
          state is TodayLoaded ||
          state is TodayLoading ||
          state is TodayLoadFailure,
      builder: (context, state) => _Card(child: _body(context, state)),
    );
  }

  Widget _body(BuildContext context, TodayState state) {
    if (state is TodayLoadFailure) {
      return _Message(
        text: state.message,
        action: 'COBA LAGI',
        onAction: () => context.read<TodayBloc>().add(LoadTodayEvent()),
      );
    }
    if (state is! TodayLoaded) {
      return const SizedBox(
        height: 96,
        child: Center(
          child: CircularProgressIndicator(color: white, strokeWidth: 2),
        ),
      );
    }

    final today = state.today;
    if (today.isDone) return _DaySummary(today: today);

    return _PunchPanel(today: today, punching: state.punching);
  }
}

class _PunchPanel extends StatelessWidget {
  final TodayAttendance today;
  final bool punching;

  const _PunchPanel({required this.today, required this.punching});

  @override
  Widget build(BuildContext context) {
    final checkingIn = today.canCheckIn;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checkingIn
                    ? '--:--'
                    : formatTimeOfDay(today.checkInAt!.toLocal()),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                checkingIn
                    ? 'Belum check-in hari ini'
                    : 'Waktu check-in${today.isLate ? ' • terlambat ${today.lateByMinutes} menit' : ''}',
                style: const TextStyle(fontSize: 12, color: white),
              ),
              if (!checkingIn) ...[
                const SizedBox(height: 2),
                Text(
                  'Sudah bekerja ${formatMinutes(today.workedMinutes)}',
                  style: const TextStyle(fontSize: 12, color: nearlyWhite),
                ),
              ],
              const SizedBox(height: 16),
              _PunchButton(
                label: checkingIn ? 'CHECK IN' : 'CHECK OUT',
                busy: punching,
                onTap: () => context
                    .read<TodayBloc>()
                    .add(checkingIn ? CheckInEvent() : CheckOutEvent()),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ShiftBadge(today: today),
      ],
    );
  }
}

class _PunchButton extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback onTap;

  const _PunchButton({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: busy ? koswaraOrange.withOpacity(0.6) : koswaraOrange,
        ),
        child: busy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(darkText),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: darkText,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// `checked_out` — the day is closed, so show what it added up to.
class _DaySummary extends StatelessWidget {
  final TodayAttendance today;

  const _DaySummary({required this.today});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hari ini selesai',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _Stat(
              label: 'Check in',
              value: formatTimeOfDay(today.checkInAt!.toLocal()),
            ),
            _Stat(
              label: 'Check out',
              value: formatTimeOfDay(today.checkOutAt!.toLocal()),
            ),
            _Stat(
              label: 'Total kerja',
              value: formatMinutes(today.workedMinutes),
            ),
          ],
        ),
        if (today.isLate) ...[
          const SizedBox(height: 10),
          Text(
            'Terlambat ${today.lateByMinutes} menit',
            style: const TextStyle(fontSize: 12, color: koswaraOrange),
          ),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: white,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: nearlyWhite)),
        ],
      ),
    );
  }
}

class _ShiftBadge extends StatelessWidget {
  final TodayAttendance today;

  const _ShiftBadge({required this.today});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: white.withOpacity(0.12),
        borderRadius: const BorderRadius.all(Radius.circular(100)),
        border: Border.all(width: 2, color: white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.schedule, color: white),
          const SizedBox(height: 4),
          Text(
            '${today.shift.start}-${today.shift.end}',
            style: const TextStyle(fontSize: 11, color: white),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final String action;
  final VoidCallback onAction;

  const _Message({
    required this.text,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: const TextStyle(color: white)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onAction,
          child: Text(
            action,
            style: const TextStyle(
              color: koswaraOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: navyDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: grey.withOpacity(0.2),
            offset: const Offset(1.1, 1.1),
            blurRadius: 10.0,
          ),
        ],
      ),
      child: child,
    );
  }
}
