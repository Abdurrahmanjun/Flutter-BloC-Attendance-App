const _monthsId = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _two(int value) => value.toString().padLeft(2, '0');

/// `09:03`. Callers pass an already-localised DateTime — the API sends RFC 3339
/// with an offset, so `.toLocal()` is theirs to decide.
String formatTimeOfDay(DateTime value) => '${_two(value.hour)}:${_two(value.minute)}';

/// `9h 27m`, or `27m` under an hour.
String formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
}

/// `9 Jul 2026`.
String formatDate(DateTime value) =>
    '${value.day} ${_monthsId[value.month - 1]} ${value.year}';

/// `9 Jul`.
String formatDayMonth(DateTime value) =>
    '${value.day} ${_monthsId[value.month - 1]}';
