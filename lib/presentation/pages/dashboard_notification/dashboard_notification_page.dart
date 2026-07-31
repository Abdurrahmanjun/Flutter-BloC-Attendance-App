import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/app_theme.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/data/models/notification/app_notification.dart';
import 'package:attendance/presentation/bloc/notification/notification_bloc.dart';
import 'package:attendance/presentation/pages/dashboard_notification/components/notification_card.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// `GET /api/notifications`, split into unread and read groups.
///
/// Read state is implied by the group a card sits in — the original's per-item
/// "Tandai dibaca" link is gone, because tapping the card is what marks it read
/// and "Tandai semua" clears the group.
class DashboardNotificationPage extends StatefulWidget {
  const DashboardNotificationPage({super.key});

  @override
  State<DashboardNotificationPage> createState() =>
      _DashboardNotificationPageState();
}

class _DashboardNotificationPageState extends State<DashboardNotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(LoadNotificationsEvent());
  }

  void _notYetAvailable(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$what belum tersedia.'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.canvasOverlay,
      child: Scaffold(
        backgroundColor: T.canvas,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) => RefreshIndicator(
              onRefresh: () async => context
                  .read<NotificationBloc>()
                  .add(LoadNotificationsEvent()),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const SizedBox(height: 14),
                  ScreenBody(child: _titleRow(context, state)),
                  const SizedBox(height: T.blockGap),
                  ..._body(context, state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titleRow(BuildContext context, NotificationState state) {
    final hasUnread = state is NotificationLoaded && state.unreadCount > 0;

    return Row(
      children: [
        const Text('Notifikasi', style: AppText.screenTitle),
        const Spacer(),
        // Nothing to clear means nothing to offer.
        if (hasUnread)
          GestureDetector(
            onTap: () => context
                .read<NotificationBloc>()
                .add(MarkAllNotificationsReadEvent()),
            behavior: HitTestBehavior.opaque,
            child: const Text('Tandai semua', style: AppText.sectionAction),
          ),
      ],
    );
  }

  List<Widget> _body(BuildContext context, NotificationState state) {
    if (state is NotificationFailure) {
      return [
        ScreenBody(
          child: _Message(
            text: state.message,
            onRetry: () => context
                .read<NotificationBloc>()
                .add(LoadNotificationsEvent()),
          ),
        ),
      ];
    }
    if (state is! NotificationLoaded) return const [_Spinner()];

    final unread = state.notifications.where((n) => n.isUnread).toList();
    final read = state.notifications.where((n) => !n.isUnread).toList();

    if (unread.isEmpty && read.isEmpty) {
      return const [
        ScreenBody(child: _Empty(text: 'Belum ada notifikasi.')),
      ];
    }

    return [
      if (unread.isNotEmpty)
        ..._group(
          context,
          eyebrow: 'Belum dibaca',
          count: state.unreadCount,
          items: unread,
        ),
      if (read.isNotEmpty)
        ..._group(context, eyebrow: 'Sebelumnya', count: null, items: read),
    ];
  }

  List<Widget> _group(
    BuildContext context, {
    required String eyebrow,
    required int? count,
    required List<AppNotification> items,
  }) {
    return [
      ScreenBody(
        child: SectionEyebrow(
          eyebrow,
          trailing: count == null ? null : _CountPill(count: count),
        ),
      ),
      const SizedBox(height: 11),
      for (final item in items) ...[
        ScreenBody(
          child: NotificationCard(
            notification: item,
            onTap: item.isUnread
                ? () => context
                    .read<NotificationBloc>()
                    .add(MarkNotificationReadEvent(item.id))
                : () {},
            // The only kind the design gives a follow-up action.
            actionLabel: item.kind == NotificationKind.attendanceLate
                ? 'Ajukan klarifikasi'
                : null,
            // TODO(api): no clarification-request endpoint in the contract.
            onAction: item.kind == NotificationKind.attendanceLate
                ? () => _notYetAvailable('Ajukan klarifikasi')
                : null,
          ),
        ),
        const SizedBox(height: 11),
      ],
      const SizedBox(height: 7),
    ];
  }
}

/// The red count beside "BELUM DIBACA".
class _CountPill extends StatelessWidget {
  final int count;

  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: T.danger500,
        borderRadius: BorderRadius.circular(T.rPill),
      ),
      child: Text(
        '$count',
        style: AppText.numeric(const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        )),
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

class _Empty extends StatelessWidget {
  final String text;

  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: T.ink300,
            ),
          ),
        ),
      );
}

class _Message extends StatelessWidget {
  final String text;
  final VoidCallback onRetry;

  const _Message({required this.text, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: AppText.body),
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
