import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// The three numbers that close out a day — Masuk / Pulang / Total — as
/// translucent tiles on a brand-blue surface.
///
/// Shared because the handoff specifies this layout once, for the hero card's
/// `out` state, and then says the day-detail view (which it does not draw)
/// should reuse it.
class DayTiles extends StatelessWidget {
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final int workedMinutes;

  const DayTiles({
    super.key,
    required this.checkInAt,
    required this.checkOutAt,
    required this.workedMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _tile(
          checkInAt == null ? '—' : formatTimeOfDay(checkInAt!.toLocal()),
          'Masuk',
        ),
        const SizedBox(width: 10),
        _tile(
          checkOutAt == null ? '—' : formatTimeOfDay(checkOutAt!.toLocal()),
          'Pulang',
        ),
        const SizedBox(width: 10),
        _tile(workedMinutes == 0 ? '—' : formatMinutes(workedMinutes), 'Total'),
      ],
    );
  }

  Widget _tile(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(T.rInput),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppText.numeric(const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                )),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.62),
                ),
              ),
            ],
          ),
        ),
      );
}
