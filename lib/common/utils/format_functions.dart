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

const _monthsIdFull = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Indexed by `DateTime.weekday`, which is 1 = Monday.
const _weekdaysId = [
  '',
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

String _two(int value) => value.toString().padLeft(2, '0');

/// `09:03`. Callers pass an already-localised DateTime — the API sends RFC 3339
/// with an offset, so `.toLocal()` is theirs to decide.
String formatTimeOfDay(DateTime value) => '${_two(value.hour)}:${_two(value.minute)}';

/// `9j 27m`, or `27m` under an hour. `j` for *jam* — the UI is Indonesian
/// throughout, and the design spells durations this way everywhere.
String formatMinutes(int totalMinutes) {
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return hours == 0 ? '${minutes}m' : '${hours}j ${minutes}m';
}

/// `9 Jul 2026`.
String formatDate(DateTime value) =>
    '${value.day} ${_monthsId[value.month - 1]} ${value.year}';

/// `9 Jul`.
String formatDayMonth(DateTime value) =>
    '${value.day} ${_monthsId[value.month - 1]}';

/// `9 Juli` — the hero card's kicker spells the month out.
String formatDayMonthFull(DateTime value) =>
    '${value.day} ${_monthsIdFull[value.month - 1]}';

/// `Juli 2026`. The month stepper and the summary card header.
String formatMonthYear(DateTime value) =>
    '${_monthsIdFull[value.month - 1]} ${value.year}';

/// `Juli 2026` from the API's `YYYY-MM` summary key. Falls back to the raw
/// string if it is not in that shape, rather than throwing inside a build.
String formatMonthKey(String month) {
  final parts = month.split('-');
  if (parts.length != 2) return month;
  final year = int.tryParse(parts[0]);
  final index = int.tryParse(parts[1]);
  if (year == null || index == null || index < 1 || index > 12) return month;
  return '${_monthsIdFull[index - 1]} $year';
}

/// `Kamis`.
String formatWeekday(DateTime value) => _weekdaysId[value.weekday];

/// `95,5` — Indonesian uses a comma as the decimal separator.
String formatDecimal(double value, {int decimals = 1}) =>
    value.toStringAsFixed(decimals).replaceAll('.', ',');

/// `Rp 1.240.000` — Indonesian groups thousands with a dot.
String formatRupiah(num amount) {
  final digits = amount.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return 'Rp ${amount < 0 ? '-' : ''}$buffer';
}

/// `19,8 km` at or above a kilometre, `180 m` below it. The geofence readout
/// switches units so the number stays two or three digits at any distance.
String formatDistance(double meters) => meters >= 1000
    ? '${formatDecimal(meters / 1000)} km'
    : '${meters.round()} m';
