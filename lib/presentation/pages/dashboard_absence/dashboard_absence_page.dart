import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:attendance/app_theme.dart';
import 'package:attendance/common/utils/design_tokens.dart';
import 'package:attendance/injection_container.dart' as di;
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/presentation/bloc/attendance/history_bloc.dart';
import 'package:attendance/presentation/pages/dashboard_absence/components/day_detail_sheet.dart';
import 'package:attendance/presentation/pages/dashboard_absence/components/entry_presentation.dart';
import 'package:attendance/presentation/pages/dashboard_absence/components/entry_row.dart';
import 'package:attendance/presentation/pages/dashboard_absence/components/month_stepper.dart';
import 'package:attendance/presentation/widgets/app_surfaces.dart';
import 'package:attendance/presentation/widgets/app_text.dart';

/// `GET /api/attendance/history` — paginated, newest first.
///
/// The month stepper is server-side: the contract scopes the feed with
/// `from`/`to`, so changing month refetches rather than filtering whatever
/// happens to be cached. The status chips stay client-side — there is no
/// status parameter on the endpoint.
///
/// This screen runs its own [HistoryBloc] rather than the app-wide one. They
/// would otherwise fight over the same feed: stepping back to June here would
/// silently empty the home screen's week strip.
class DashboardAbsencePage extends StatelessWidget {
  const DashboardAbsencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryBloc>(
      create: (_) => di.sl<HistoryBloc>(),
      child: const _AbsenceView(),
    );
  }
}

class _AbsenceView extends StatefulWidget {
  const _AbsenceView();

  @override
  State<_AbsenceView> createState() => _DashboardAbsencePageState();
}

class _DashboardAbsencePageState extends State<_AbsenceView> {
  final _scrollController = ScrollController();

  late DateTime _month = _thisMonth();
  HistoryFilter _filter = HistoryFilter.semua;
  bool _newestFirst = true;

  static DateTime _thisMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(LoadHistoryEvent(month: _month));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<HistoryBloc>().add(LoadMoreHistoryEvent());
    }
  }

  List<AttendanceEntry> _visible(List<AttendanceEntry> entries) {
    // Only the chips filter here; the month came scoped from the server.
    final rows = entries.where(_filter.matches).toList()
      ..sort((a, b) => _newestFirst
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date));
    return rows;
  }

  void _pickSort() async {
    final choice = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (newest, label) in [
              (true, 'Terbaru dulu'),
              (false, 'Terlama dulu'),
            ])
              ListTile(
                title: Text(label),
                selected: _newestFirst == newest,
                onTap: () => Navigator.pop(sheetContext, newest),
              ),
          ],
        ),
      ),
    );
    if (choice != null && mounted) setState(() => _newestFirst = choice);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.canvasOverlay,
      child: Scaffold(
        backgroundColor: T.canvas,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) => RefreshIndicator(
              onRefresh: () async => context
                  .read<HistoryBloc>()
                  .add(LoadHistoryEvent(month: _month)),
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const SizedBox(height: 14),
                  _Constrained(child: _titleRow()),
                  const SizedBox(height: T.blockGap),
                  _Constrained(
                    child: MonthStepper(
                      month: _month,
                      onChanged: (month) {
                        setState(() => _month = month);
                        context
                            .read<HistoryBloc>()
                            .add(LoadHistoryEvent(month: month));
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Full-bleed: the chip strip scrolls past the screen edge.
                  _FilterChips(
                    selected: _filter,
                    onSelected: (filter) => setState(() => _filter = filter),
                  ),
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

  Widget _titleRow() {
    return Row(
      children: [
        const Text('Absensi', style: AppText.screenTitle),
        const Spacer(),
        GestureDetector(
          onTap: _pickSort,
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: T.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: T.border),
            ),
            child: const Icon(Icons.tune_rounded, size: 20, color: T.ink700),
          ),
        ),
      ],
    );
  }

  List<Widget> _body(BuildContext context, HistoryState state) {
    if (state is HistoryFailure) {
      return [
        _Constrained(
          child: _Message(
            text: state.message,
            action: 'Coba lagi',
            onAction: () => context
                .read<HistoryBloc>()
                .add(LoadHistoryEvent(month: _month)),
          ),
        ),
      ];
    }
    if (state is! HistoryLoaded) return const [_Spinner()];

    final rows = _visible(state.entries);

    if (rows.isEmpty) {
      return [
        _Constrained(
          child: _Empty(
            text: _filter == HistoryFilter.semua
                ? 'Belum ada catatan absensi bulan ini.'
                : 'Tidak ada hari berstatus "${_filter.label}" bulan ini.',
          ),
        ),
      ];
    }

    // The handoff heads the list "MINGGU INI"; anything older gets its own
    // group so a long month does not sit under a lie.
    final startOfWeek = _startOfThisWeek();
    final thisWeek =
        rows.where((e) => !e.date.toLocal().isBefore(startOfWeek)).toList();
    final earlier =
        rows.where((e) => e.date.toLocal().isBefore(startOfWeek)).toList();

    return [
      if (thisWeek.isNotEmpty) ..._group('Minggu ini', thisWeek),
      if (earlier.isNotEmpty) ..._group('Sebelumnya', earlier),
      _Constrained(
        child: _Footer(loading: state.loadingMore, hasMore: state.hasMore),
      ),
    ];
  }

  static DateTime _startOfThisWeek() {
    final now = DateUtils.dateOnly(DateTime.now());
    return now.subtract(Duration(days: now.weekday - 1));
  }

  List<Widget> _group(String eyebrow, List<AttendanceEntry> entries) {
    return [
      _Constrained(child: SectionEyebrow(eyebrow)),
      const SizedBox(height: 11),
      for (final entry in entries) ...[
        _Constrained(
          child: EntryRow(
            entry: entry,
            onTap: () => DayDetailSheet.show(context, entry),
          ),
        ),
        const SizedBox(height: 9),
      ],
      const SizedBox(height: 9),
    ];
  }
}

/// Screen padding plus the tablet content cap, applied per row so the chip
/// strip can opt out and bleed to the edge.
class _Constrained extends StatelessWidget {
  final Widget child;

  const _Constrained({required this.child});

  @override
  Widget build(BuildContext context) => ScreenBody(child: child);
}

class _FilterChips extends StatelessWidget {
  final HistoryFilter selected;
  final ValueChanged<HistoryFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: T.maxContentWidth),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: T.screenX),
          child: Row(
            children: [
              for (final filter in HistoryFilter.values) ...[
                if (filter != HistoryFilter.values.first)
                  const SizedBox(width: 7),
                _Chip(
                  label: filter.label,
                  active: filter == selected,
                  onTap: () => onSelected(filter),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: T.stateChange,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? T.ink900 : T.surface,
          borderRadius: BorderRadius.circular(T.rPill),
          border: Border.all(color: active ? T.ink900 : T.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : T.ink700,
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool loading;
  final bool hasMore;

  const _Footer({required this.loading, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    if (!hasMore && !loading) return const SizedBox(height: 8);

    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          'Memuat lebih banyak…',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: T.ink300,
          ),
        ),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
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
        padding: const EdgeInsets.symmetric(vertical: 56),
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
  final String action;
  final VoidCallback onAction;

  const _Message({
    required this.text,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: AppText.body),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(action, style: AppText.sectionAction),
            ),
          ),
        ],
      ),
    );
  }
}
