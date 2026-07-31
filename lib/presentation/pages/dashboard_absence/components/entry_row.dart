import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/presentation/pages/dashboard_absence/components/entry_presentation.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// One day in the history list: status rail, date and punches, badge and total.
class EntryRow extends StatelessWidget {
  final AttendanceEntry entry;
  final VoidCallback onTap;

  const EntryRow({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final look = EntryPresentation.of(entry);
    final date = entry.date.toLocal();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: T.surface,
          borderRadius: BorderRadius.circular(T.rRow),
          border: Border.all(color: T.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stretched to the row's height, with a floor so a short row
              // still reads as a status rail rather than a dot.
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: look.rail,
                    borderRadius: BorderRadius.circular(T.rPill),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          formatDayMonth(date),
                          style: AppText.numeric(AppText.rowTitle),
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            formatWeekday(date),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: T.ink300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      EntryPresentation.detailFor(entry),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.numeric(const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: T.ink500,
                      )),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(
                    label: look.label,
                    background: look.badgeBackground,
                    foreground: look.badgeForeground,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    EntryPresentation.totalFor(entry),
                    style: AppText.numeric(const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: T.ink400,
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
