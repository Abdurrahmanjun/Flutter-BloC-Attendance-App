import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// How one notification kind reads: its icon, the chip tint behind it, and the
/// colour of the accent rail down the left of an unread card.
class _Look {
  final IconData icon;
  final Color chip;
  final Color stroke;
  final Color rail;

  const _Look({
    required this.icon,
    required this.chip,
    required this.stroke,
    required this.rail,
  });

  factory _Look.of(NotificationKind kind) => switch (kind) {
        NotificationKind.overtimeRequest => const _Look(
            icon: Icons.description_outlined,
            chip: T.brand100,
            stroke: T.brand600,
            rail: T.brand600,
          ),
        NotificationKind.overtimeApproved => const _Look(
            icon: Icons.verified_outlined,
            chip: T.successChip,
            stroke: T.success500,
            rail: T.success500,
          ),
        NotificationKind.attendanceLate => const _Look(
            icon: Icons.schedule_rounded,
            chip: T.accent50,
            stroke: T.accent700,
            rail: T.accent500,
          ),
        NotificationKind.attendanceMissingCheckout => const _Look(
            icon: Icons.logout_rounded,
            chip: T.accent50,
            stroke: T.accent700,
            rail: T.accent500,
          ),
        NotificationKind.leaveApproved => const _Look(
            icon: Icons.check_rounded,
            chip: T.successChip,
            stroke: T.success500,
            rail: T.success500,
          ),
        NotificationKind.leaveRejected => const _Look(
            icon: Icons.close_rounded,
            chip: T.dangerChip,
            stroke: T.danger500,
            rail: T.danger500,
          ),
        NotificationKind.announcement => const _Look(
            icon: Icons.flag_outlined,
            chip: Color(0xFFF1F3F7),
            stroke: T.ink700,
            rail: T.ink300,
          ),
      };
}

/// One row of the feed.
///
/// Read state is carried by the group the card sits in, not by a per-item
/// label: the redesign removed the original's "Tandai dibaca" link, because
/// tapping the card is what marks it read.
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  /// Shown under the body — "Ajukan klarifikasi" on a late-arrival notice.
  final String? actionLabel;
  final VoidCallback? onAction;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final unread = notification.isUnread;
    final look = _Look.of(notification.kind);

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: T.surface,
        borderRadius: BorderRadius.circular(T.rRow),
        // An unread card carries a stronger border, and a shadow a read one
        // does not.
        border: Border.all(color: unread ? T.borderUnread : T.borderSoft),
        boxShadow: unread ? T.unreadShadow : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (unread)
              // The rail is inset 18px top and bottom, rounded on its right.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: look.rail,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconChip(
                      icon: look.icon,
                      background: look.chip,
                      foreground: look.stroke,
                    ),
                    const SizedBox(width: 13),
                    Expanded(child: _body(unread)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      // Read cards sit back at 85%, which is what separates the two groups
      // visually once the rail and shadow are gone.
      child: unread ? card : Opacity(opacity: 0.85, child: card),
    );
  }

  Widget _body(bool unread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: unread ? FontWeight.w800 : FontWeight.w700,
                  letterSpacing: -0.145,
                  color: unread ? T.ink900 : T.ink700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatDayMonth(notification.createdAt.toLocal()),
              style: AppText.numeric(const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: T.ink300,
              )),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          notification.body,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            fontWeight: FontWeight.w500,
            color: unread ? T.ink500 : T.ink400,
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(height: 9),
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: T.brand600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
