import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';

/// Chevron / month / chevron. Stepping forward past the current month is
/// disabled — there is no attendance to read in the future.
class MonthStepper extends StatelessWidget {
  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  const MonthStepper({
    super.key,
    required this.month,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final canGoForward =
        month.year < now.year || (month.year == now.year && month.month < now.month);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.rButton),
        border: Border.all(color: T.border),
      ),
      child: Row(
        children: [
          _Chevron(
            icon: Icons.chevron_left_rounded,
            onTap: () => onChanged(DateTime(month.year, month.month - 1)),
          ),
          Expanded(
            child: Text(
              formatMonthYear(month),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: T.ink900,
              ),
            ),
          ),
          _Chevron(
            icon: Icons.chevron_right_rounded,
            onTap: canGoForward
                ? () => onChanged(DateTime(month.year, month.month + 1))
                : null,
          ),
        ],
      ),
    );
  }
}

class _Chevron extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _Chevron({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          icon,
          size: 22,
          color: onTap == null ? T.borderStrong : T.ink700,
        ),
      ),
    );
  }
}
