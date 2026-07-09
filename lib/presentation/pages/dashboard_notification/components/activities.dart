import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/presentation/bloc/notification/notification_bloc.dart';

/// `GET /api/notifications` — replaces the hardcoded five-item feed.
class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  State<Activities> createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                TextButton(
                  onPressed: () => context
                      .read<NotificationBloc>()
                      .add(LoadNotificationsEvent()),
                  child: const Text('COBA LAGI'),
                ),
              ],
            ),
          );
        }
        if (state is! NotificationLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.notifications.isEmpty) {
          return const Center(child: Text('Belum ada notifikasi.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recent",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: deactivatedText,
                    ),
                  ),
                  if (state.unreadCount > 0)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: infoRed,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${state.unreadCount} baru',
                        style: const TextStyle(
                          color: white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              child: RefreshIndicator(
                onRefresh: () async => context
                    .read<NotificationBloc>()
                    .add(LoadNotificationsEvent()),
                child: ListView.builder(
                  itemCount: state.notifications.length,
                  itemBuilder: (context, index) => _NotificationTile(
                    notification: state.notifications[index],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  static IconData _iconFor(NotificationKind kind) => switch (kind) {
        NotificationKind.attendanceLate => Icons.schedule,
        NotificationKind.attendanceMissingCheckout => Icons.logout,
        NotificationKind.leaveApproved => Icons.check_circle_outline,
        NotificationKind.leaveRejected => Icons.cancel_outlined,
        NotificationKind.overtimeRequest => Icons.pending_actions_rounded,
        NotificationKind.overtimeApproved => Icons.verified_outlined,
        NotificationKind.announcement => Icons.campaign_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final unread = notification.isUnread;

    return InkWell(
      onTap: unread
          ? () => context
              .read<NotificationBloc>()
              .add(MarkNotificationReadEvent(notification.id))
          : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: unread ? const Color(0xFFEEEEEE) : white,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(notification.kind), color: gray).paddingTop(2),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: lightText,
                              fontWeight:
                                  unread ? FontWeight.bold : FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formatDayMonth(notification.createdAt.toLocal()),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    4.height,
                    Text(notification.body),
                    if (unread) ...[
                      8.height,
                      const Text(
                        'Tandai dibaca',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ).paddingAll(4),
      ),
    );
  }
}
