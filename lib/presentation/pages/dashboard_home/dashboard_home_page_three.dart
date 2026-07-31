import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/app_theme.dart';
import 'package:attendance/common/settings/app_settings.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/presentation/bloc/announcement/announcement_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/history_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/summary_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';
import 'package:attendance/presentation/bloc/notification/notification_bloc.dart';
import 'package:attendance/presentation/bloc/office/office_bloc.dart';
import 'package:attendance/presentation/bloc/profile/profile_bloc.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/announcement_card.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/greeting_row.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/hero_card.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/monthly_summary_card.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/pengajuan_grid.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';

/// Beranda. One screen, one primary action: today's status and the punch that
/// follows from it, with everything else arranged beneath it.
class DashboardHomePageThree extends StatefulWidget {
  /// Selects another tab on the shell — the bell goes to Notifikasi, "Detail"
  /// and "Riwayat" go to Absensi. Home does not push routes of its own.
  final void Function(int index)? onNavigate;

  /// Opens Laporan bulanan for the given month, inside the Absensi tab.
  final void Function(DateTime month)? onOpenReport;

  const DashboardHomePageThree({
    super.key,
    this.onNavigate,
    this.onOpenReport,
  });

  @override
  State<DashboardHomePageThree> createState() => _DashboardHomePageThreeState();
}

class _DashboardHomePageThreeState extends State<DashboardHomePageThree> {
  @override
  void initState() {
    super.initState();
    _load();
    // Live, not one-shot: the hero's distance meter is meant to fill as the
    // user walks toward the office. Skipped entirely when the user has turned
    // "Lokasi saat check-in" off in Pengaturan.
    if (di.sl<AppSettings>().locationOnCheckIn.value) {
      context.read<OfficeBloc>().add(WatchProximityEvent());
    }
  }

  @override
  void dispose() {
    context.read<OfficeBloc>().add(StopWatchingProximityEvent());
    super.dispose();
  }

  void _load() {
    context.read<TodayBloc>().add(LoadTodayEvent());
    context.read<SummaryBloc>().add(LoadSummaryEvent(SummaryBloc.currentMonth()));
    context.read<AnnouncementBloc>().add(LoadAnnouncementsEvent());
    context.read<ProfileBloc>().add(LoadProfileEvent());
    // The bell's unread dot and the week strip both read from feeds this
    // screen does not otherwise own.
    context.read<NotificationBloc>().add(LoadNotificationsEvent());
    context.read<HistoryBloc>().add(LoadHistoryEvent());
  }

  void _unavailable(String what) {
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
          child: RefreshIndicator(
            onRefresh: () async {
              _load();
              if (di.sl<AppSettings>().locationOnCheckIn.value) {
                context.read<OfficeBloc>().add(CheckProximityEvent());
              }
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                ScreenBody(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      GreetingRow(
                        onBellTap: () => widget.onNavigate?.call(2),
                      ),
                      const SizedBox(height: T.blockGap),
                      const HeroCard(),
                      const SizedBox(height: T.blockGap),
                      PengajuanGrid(
                        onUnavailable: (label) =>
                            _unavailable('Pengajuan $label'),
                        onHistory: () => widget.onNavigate?.call(1),
                      ),
                      const SizedBox(height: T.blockGap),
                      MonthlySummaryCard(
                        onDetail: () =>
                            widget.onOpenReport?.call(DateTime.now()),
                      ),
                      const SizedBox(height: T.blockGap),
                      const AnnouncementCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
