import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/common/network/dev_prefer.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';

/// Debug-only. Prism is a stateless mock, so a check-in never makes the next
/// `today` return `checked_in`. These selects set the `Prefer` header the mock
/// honours, which is what makes the whole day — including the 409 and the
/// geofence 422 — walkable from inside the running app.
///
/// The dashed border and the DEBUG pill are the design's way of saying this is
/// not production UI. The whole group compiles out of a release build behind
/// [kDebugMode].
class DevPreferMenu extends StatelessWidget {
  const DevPreferMenu({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionEyebrow('Mock API', trailing: _DebugPill()),
        const SizedBox(height: 11),
        _DashedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Prism memutar contoh tetap. Pilih respons yang dikembalikan.',
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: T.ink400,
                ),
              ),
              const SizedBox(height: 14),
              _PreferSelect(
                endpoint: 'GET /attendance/today',
                notifier: DevPrefer.today,
                options: DevPrefer.todayOptions,
                // Re-read immediately so the home screen reflects the choice.
                onChanged: () => context.read<TodayBloc>().add(LoadTodayEvent()),
              ),
              const SizedBox(height: 14),
              _PreferSelect(
                endpoint: 'POST /check-in · /check-out',
                notifier: DevPrefer.punch,
                options: DevPrefer.punchOptions,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DebugPill extends StatelessWidget {
  const _DebugPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: T.accent50,
        borderRadius: BorderRadius.circular(T.rPill),
      ),
      child: const Text(
        'DEBUG',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: T.accentText,
        ),
      ),
    );
  }
}

/// A dashed-border card. Flutter has no dashed border, so it is painted.
class _DashedCard extends StatelessWidget {
  final Widget child;

  const _DashedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFE),
          borderRadius: BorderRadius.circular(T.rCard),
        ),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = T.borderDashed
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(T.rCard),
      ));

    // Walk the outline drawing 5px on, 4px off.
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 5), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A monospace endpoint label over a white select row.
class _PreferSelect extends StatelessWidget {
  final String endpoint;
  final ValueNotifier<String?> notifier;
  final Map<String, String?> options;
  final VoidCallback? onChanged;

  const _PreferSelect({
    required this.endpoint,
    required this.notifier,
    required this.options,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: notifier,
      builder: (context, current, _) {
        final label = options.entries
            .firstWhere(
              (entry) => entry.value == current,
              orElse: () => options.entries.first,
            )
            .key;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              endpoint,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: T.ink600,
              ),
            ),
            const SizedBox(height: 7),
            GestureDetector(
              onTap: () => _pick(context, current),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: T.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: T.borderStrong),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: T.ink900,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: T.ink300,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pick(BuildContext context, String? current) async {
    final choice = await showModalBottomSheet<MapEntry<String, String?>>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.entries
              .map((entry) => ListTile(
                    title: Text(entry.key),
                    subtitle: entry.value == null
                        ? const Text('no Prefer header')
                        : Text('Prefer: ${entry.value}'),
                    selected: entry.value == current,
                    onTap: () => Navigator.pop(sheetContext, entry),
                  ))
              .toList(),
        ),
      ),
    );

    if (choice == null) return;
    notifier.value = choice.value;
    onChanged?.call();
  }
}
