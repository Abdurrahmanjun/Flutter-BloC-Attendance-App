import 'package:flutter/material.dart';

import 'package:attendance/common/utils/design_tokens.dart';

/// The design's type scale, named by role rather than by size so screens read
/// as the handoff does. Sizes, weights, and tracking are transcribed exactly;
/// anything numeric carries `tabular-nums` as the handoff requires.
class AppText {
  AppText._();

  static const _tabular = [FontFeature.tabularFigures()];

  /// 26/800/-0.03em. "Absensi", "Notifikasi", "Pengaturan".
  static const screenTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.78, // -0.03em
    color: T.ink900,
    height: 1.2,
  );

  /// 34/800/-0.03em, two lines at 1.1.
  static const loginHeadline = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.02,
    height: 1.1,
    color: Colors.white,
  );

  /// 36/800/-0.03em. The hero metric when there is a duration to show.
  static const heroMetric = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.08,
    height: 1.1,
    color: Colors.white,
    fontFeatures: _tabular,
  );

  /// 24/800/-0.03em. The hero metric when it is the words "Belum absen".
  static const heroMetricSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.72,
    height: 1.1,
    color: Colors.white,
  );

  /// 44/800/-0.04em. The report's attendance percentage.
  static const bigStat = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.76,
    height: 1,
    color: Colors.white,
    fontFeatures: _tabular,
  );

  /// 15/800/-0.01em. "Pengajuan", "Juli 2026".
  static const sectionHeader = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.15,
    color: T.ink900,
  );

  /// 13/700 brand. "Riwayat", "Detail", "Tandai semua".
  static const sectionAction = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: T.brand600,
  );

  /// 15.5/800/-0.01em. A list row's leading title.
  static const rowTitle = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.155,
    color: T.ink900,
  );

  /// 13/1.55. Body copy.
  static const body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.55,
    color: T.ink500,
  );

  /// 12/700. Timestamps, counts, secondary values.
  static const meta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: T.ink400,
  );

  /// 11.5/800/0.10em uppercase. Section eyebrows — "MINGGU INI".
  static const eyebrow = TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.15, // 0.10em
    color: T.ink300,
  );

  /// 11/800 on a filled pill.
  static const badge = TextStyle(fontSize: 11, fontWeight: FontWeight.w800);

  /// 10.5/600. Tab label; the active tab overrides to w800.
  static const tabLabel = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.105,
  );

  /// Adds `tabular-nums` to any style, for times and durations composed
  /// outside the roles above.
  static TextStyle numeric(TextStyle style) =>
      style.copyWith(fontFeatures: _tabular);
}
