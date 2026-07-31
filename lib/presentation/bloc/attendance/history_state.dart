part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<AttendanceEntry> entries;
  final int page;
  final bool hasMore;
  final int totalEntries;
  final bool loadingMore;

  /// The month these entries were scoped to, or null when the feed is
  /// unscoped. Readers use it to tell "this month is empty" apart from
  /// "these entries are some other month's".
  final DateTime? month;

  const HistoryLoaded({
    required this.entries,
    required this.page,
    required this.hasMore,
    required this.totalEntries,
    this.loadingMore = false,
    this.month,
  });

  HistoryLoaded copyWith({bool? loadingMore, bool? hasMore}) => HistoryLoaded(
        entries: entries,
        page: page,
        hasMore: hasMore ?? this.hasMore,
        totalEntries: totalEntries,
        loadingMore: loadingMore ?? this.loadingMore,
        month: month,
      );

  @override
  List<Object?> get props =>
      [entries, page, hasMore, totalEntries, loadingMore, month];
}

class HistoryFailure extends HistoryState {
  final String message;

  const HistoryFailure(this.message);

  @override
  List<Object?> get props => [message];
}
