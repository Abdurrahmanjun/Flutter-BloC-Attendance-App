import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/common/utils/constants.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/monthly_summary.dart';
import 'package:attendance/presentation/bloc/attendance/summary_bloc.dart';

/// `GET /api/attendance/summary?month=YYYY-MM`, rendered. Previously this card
/// showed a hardcoded calorie tracker.
///
/// `late` is a subset of `present`, so the legend splits `present` into on-time
/// and late rather than listing them as siblings, and the ring shows `present`
/// out of `workingDays`. Adding present + late + absent + leave would
/// overcount, which is exactly the mistake the contract warns about.
class HrmDiagramCard extends StatelessWidget {
  const HrmDiagramCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) => _Card(
        child: switch (state) {
          SummaryLoaded(:final summary) => _Content(summary: summary),
          SummaryFailure(:final message) => _Failure(
              message: message,
              onRetry: () => context
                  .read<SummaryBloc>()
                  .add(LoadSummaryEvent(SummaryBloc.currentMonth())),
            ),
          _ => const SizedBox(
              height: 140,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final MonthlySummary summary;

  const _Content({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ringkasan ${summary.month}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: darkerText,
              ),
            ),
            Text(
              '${summary.workingDays} hari kerja',
              style: TextStyle(fontSize: 12, color: grey.withOpacity(0.7)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  _Legend(
                    label: 'Tepat waktu',
                    value: summary.onTime,
                    color: HexColor('#87A0E5'),
                  ),
                  _Legend(
                    label: 'Terlambat',
                    value: summary.late,
                    color: koswaraOrange,
                  ),
                  _Legend(
                    label: 'Absen',
                    value: summary.absent,
                    color: infoRed,
                  ),
                  _Legend(
                    label: 'Cuti',
                    value: summary.leave,
                    color: infoGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _PresenceRing(summary: summary),
          ],
        ),
        const Divider(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Footer(
              label: 'Rata-rata check-in',
              value: summary.averageCheckInTime ?? '—',
            ),
            _Footer(
              label: 'Lembur',
              value: formatMinutes(summary.overtimeMinutes),
            ),
          ],
        ),
      ],
    );
  }
}

/// `present` out of the month's working days. `present` already includes the
/// late days.
class _PresenceRing extends StatelessWidget {
  final MonthlySummary summary;

  const _PresenceRing({required this.summary});

  @override
  Widget build(BuildContext context) {
    final ratio = summary.workingDays == 0
        ? 0.0
        : (summary.present / summary.workingDays).clamp(0.0, 1.0);

    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(108, 108),
            painter: CurvePainter(
              // CurvePainter takes a sweep in degrees.
              angle: 360 * ratio,
              colors: [nearlyDarkBlue, HexColor('#8A98E8'), HexColor('#8A98E8')],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${summary.present}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: darkerText,
                ),
              ),
              Text(
                'hadir',
                style: TextStyle(fontSize: 12, color: grey.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _Legend({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: grey.withOpacity(0.7),
                  ),
                ),
                Text(
                  '$value hari',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: darkerText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final String label;
  final String value;

  const _Footer({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: grey.withOpacity(0.7)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: darkerText,
          ),
        ),
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
        Text(message, style: const TextStyle(color: darkerText)),
        TextButton(onPressed: onRetry, child: const Text('COBA LAGI')),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
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

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        new Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}
