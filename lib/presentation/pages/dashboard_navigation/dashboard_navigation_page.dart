import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/presentation/pages/dashboard_absence/dashboard_absence_page.dart';
import 'package:attendance/presentation/pages/dashboard_home/dashboard_home_page_three.dart';
import 'package:attendance/presentation/pages/dashboard_notification/dashboard_notification_page.dart';
import 'package:attendance/presentation/pages/dashboard_settings/dashboard_settings_page.dart';
import 'package:attendance/presentation/pages/monthly_report/monthly_report_page.dart';
import 'package:attendance/presentation/pages/profile/profile_page.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// The five-tab shell. Profil is a tab in the redesign rather than a route
/// pushed from the home avatar, which is why there are five items where the
/// old `BottomNavyBar` had four.
///
/// The bar is hand-built because the active item both takes a pill background
/// and *widens* — `flex: 1.5` against the others' 1 — which no off-the-shelf
/// Flutter nav bar does.
class HomeNavBarPage extends StatefulWidget {
  const HomeNavBarPage({super.key});

  @override
  State<HomeNavBarPage> createState() => _HomeNavBarPageState();
}

class _HomeNavBarPageState extends State<HomeNavBarPage> {
  int currentIndex = 0;

  /// When set, the Absensi tab shows the monthly report for this month instead
  /// of the history list. The handoff keeps the tab bar on that screen with
  /// Absensi still active, so the report lives inside the tab rather than being
  /// pushed over the whole shell.
  DateTime? reportMonth;

  static const _items = <_NavItem>[
    _NavItem('Beranda', Icons.home_rounded, Icons.home_outlined),
    _NavItem('Absensi', Icons.event_available_rounded,
        Icons.event_available_outlined),
    _NavItem('Notifikasi', Icons.notifications_rounded,
        Icons.notifications_none_rounded),
    _NavItem('Profil', Icons.person_rounded, Icons.person_outline_rounded),
    _NavItem('Atur', Icons.settings_rounded, Icons.settings_outlined),
  ];

  void _select(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
  }

  /// Home's "Detail" and "Riwayat" both land in the Absensi tab; "Detail" opens
  /// the report on top of it.
  void _openReport(DateTime month) {
    setState(() {
      currentIndex = 1;
      reportMonth = month;
    });
  }

  void _closeReport() => setState(() => reportMonth = null);

  Widget _page(int index) => switch (index) {
        1 => reportMonth == null
            ? const DashboardAbsencePage()
            : MonthlyReportPage(month: reportMonth!, onBack: _closeReport),
        2 => const DashboardNotificationPage(),
        3 => const ProfilePage(),
        4 => const DashboardSettingsPage(),
        _ => DashboardHomePageThree(
            onNavigate: _select,
            onOpenReport: _openReport,
          ),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.canvas,
      // Keep each tab's scroll position and bloc-driven state across switches;
      // the old shell rebuilt the page from scratch every time.
      body: IndexedStack(
        index: currentIndex,
        children: [for (var i = 0; i < _items.length; i++) _page(i)],
      ),
      bottomNavigationBar: _TabBar(
        items: _items,
        currentIndex: currentIndex,
        onSelected: _select,
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData activeIcon;
  final IconData icon;

  const _NavItem(this.label, this.activeIcon, this.icon);
}

class _TabBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  const _TabBar({
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xF0FFFFFF), // rgba(255,255,255,.94)
            border: Border(top: BorderSide(color: T.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    // The active tab widens to 1.5x, animated over 180ms.
                    AnimatedFlex(
                      flex: i == currentIndex ? 3 : 2,
                      child: _TabItem(
                        item: items[i],
                        active: i == currentIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `Flexible` cannot animate its own flex, so the transition is driven by a
/// tween over the flex value instead.
///
/// The fit must be **tight**: `Flexible`'s default loose fit lets each item
/// shrink to its own content, which silently discards the flex ratio entirely
/// and leaves the five tabs sized by how long their labels happen to be.
class AnimatedFlex extends StatelessWidget {
  final int flex;
  final Widget child;

  const AnimatedFlex({super.key, required this.flex, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: flex.toDouble()),
      duration: T.stateChange,
      curve: Curves.easeOut,
      builder: (context, value, child) => Flexible(
        fit: FlexFit.tight,
        // Integer flex, so the tween is scaled up and rounded rather than
        // truncated to a two-step jump.
        flex: (value * 100).round(),
        child: child!,
      ),
      child: child,
    );
  }
}

class _TabItem extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? T.brand600 : T.ink250;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: T.navChange,
        // 8 top / 4 sides / 6 bottom, per the handoff's `8px 4px 6px`.
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
        decoration: BoxDecoration(
          color: active ? T.brand100 : Colors.transparent,
          borderRadius: BorderRadius.circular(T.rInput),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? item.activeIcon : item.icon, size: 21, color: color),
            const SizedBox(height: 3),
            // "Notifikasi" at 10.5px only just fits an inactive tab's share of
            // a 388px viewport; scaleDown keeps it legible on anything
            // narrower instead of overflowing the pill.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.label,
                maxLines: 1,
                softWrap: false,
                style: AppText.tabLabel.copyWith(
                  color: color,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
