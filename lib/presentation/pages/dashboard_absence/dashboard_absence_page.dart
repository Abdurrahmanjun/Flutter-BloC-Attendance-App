import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart' hide white;

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/common/utils/format_functions.dart';
import 'package:attendance/data/models/attendance/attendance_entry.dart';
import 'package:attendance/presentation/bloc/attendance/history_bloc.dart';

/// `GET /api/attendance/history` — paginated, newest first.
class DashboardAbsencePage extends StatefulWidget {
  const DashboardAbsencePage({super.key});

  @override
  State<DashboardAbsencePage> createState() => _DashboardAbsencePageState();
}

class _DashboardAbsencePageState extends State<DashboardAbsencePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(LoadHistoryEvent());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Absence",
        color: context.scaffoldBackgroundColor,
        elevation: 0,
        showBack: false,
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryFailure) {
            return _Retry(
              message: state.message,
              onRetry: () =>
                  context.read<HistoryBloc>().add(LoadHistoryEvent()),
            );
          }
          if (state is! HistoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.entries.isEmpty) {
            return const Center(child: Text('Belum ada riwayat absensi.'));
          }

          return RefreshIndicator(
            onRefresh: () async =>
                context.read<HistoryBloc>().add(LoadHistoryEvent()),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8),
              // One extra row for the footer.
              itemCount: state.entries.length + 1,
              itemBuilder: (context, index) {
                if (index == state.entries.length) {
                  return _Footer(
                    loading: state.loadingMore,
                    hasMore: state.hasMore,
                    total: state.totalEntries,
                  );
                }
                return _EntryTile(entry: state.entries[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final AttendanceEntry entry;

  const _EntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    // There is no `late` entry status: lateness is a flag on a present day.
    final (label, color) = switch (entry.status) {
      EntryStatus.present when entry.isLate => ('Terlambat', koswaraOrange),
      EntryStatus.present => ('Hadir', infoGreen),
      EntryStatus.absent => ('Absen', infoRed),
      EntryStatus.leave => ('Cuti', nearlyBlue),
      EntryStatus.holiday => ('Libur', deactivatedText),
    };

    // absent / leave / holiday days carry no punches.
    final hasPunches = entry.checkInAt != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(entry.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: darkerText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  hasPunches
                      ? '${formatTimeOfDay(entry.checkInAt!.toLocal())} — '
                          '${entry.checkOutAt == null ? 'belum check-out' : formatTimeOfDay(entry.checkOutAt!.toLocal())}'
                      : '—',
                  style: const TextStyle(fontSize: 13, color: lightText),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              if (hasPunches) ...[
                const SizedBox(height: 6),
                Text(
                  formatMinutes(entry.workedMinutes),
                  style: const TextStyle(fontSize: 12, color: lightText),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final bool loading;
  final bool hasMore;
  final int total;

  const _Footer({
    required this.loading,
    required this.hasMore,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                hasMore ? 'Memuat lebih banyak…' : '$total catatan',
                style: const TextStyle(color: deactivatedText, fontSize: 12),
              ),
      ),
    );
  }
}

class _Retry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _Retry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          TextButton(onPressed: onRetry, child: const Text('COBA LAGI')),
        ],
      ),
    );
  }
}
