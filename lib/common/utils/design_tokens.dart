import 'package:flutter/material.dart';

/// The redesign's token table, transcribed from the design handoff.
///
/// These supersede the palette in `colors.dart`, which is a leftover from the
/// template this app was forked from (its `primaryColor` is a green no screen
/// actually renders). Screens are moved over one at a time; until the last one
/// is converted both files coexist.
///
/// Layout values are given at a 388 x 840 logical viewport, which is what
/// Flutter's logical pixels already are — so they are used verbatim, not scaled.
class T {
  T._();

  // ---------------------------------------------------------------- color ---

  /// Primary. Buttons, active tab, login header, profile header, links.
  static const brand600 = Color(0xFF0E5FA4);

  /// Hero card gradient end, pressed primary.
  static const brand700 = Color(0xFF0B4E86);

  /// Hero card gradient start.
  static const brand500 = Color(0xFF1069B3);

  /// Active tab pill background, icon chip tint.
  static const brand100 = Color(0xFFE8F1FA);

  /// Inactive chart bars.
  static const brand200 = Color(0xFFBEDCF3);

  /// Amber. Working badge, progress fill, geofence marker, announcement kicker.
  static const accent500 = Color(0xFFF2B441);

  /// Amber icon stroke.
  static const accent700 = Color(0xFFC98A0B);

  /// Amber chip background.
  static const accent50 = Color(0xFFFDF3DF);

  /// Amber-on-light text.
  static const accentText = Color(0xFFA97708);

  /// Text on an amber fill.
  static const accentOnFill = Color(0xFF3D2C05);

  /// Amber stat-tile background, distinct from [accent50].
  static const accentTile = Color(0xFFFEF7E6);

  /// Amber stat-tile label.
  static const accentTileLabel = Color(0xFF8A7038);

  static const success500 = Color(0xFF1F9D74);

  /// Present chip.
  static const success50 = Color(0xFFEAF7F1);

  /// Present stat tile — one step lighter than the chip.
  static const successTile = Color(0xFFF1F9F5);

  static const successText = Color(0xFF127A58);

  /// Present stat-tile label.
  static const successTileLabel = Color(0xFF4F7D6C);

  /// Reimbursement icon chip.
  static const successChip = Color(0xFFE8F6F0);

  /// Absent, unread dot.
  static const danger500 = Color(0xFFE05252);

  /// Absent chip.
  static const danger50 = Color(0xFFFDF0F0);

  /// Logout button fill.
  static const dangerSurface = Color(0xFFFEF6F6);

  /// Sick-leave icon chip.
  static const dangerChip = Color(0xFFFDEEEE);

  static const dangerText = Color(0xFFC24141);

  /// Logout label.
  static const dangerStrong = Color(0xFFD34747);

  /// Logout border.
  static const dangerBorder = Color(0xFFF6D5D5);

  /// Absent stat-tile label.
  static const dangerTileLabel = Color(0xFF965858);

  /// Headings, primary text, dark buttons.
  static const ink900 = Color(0xFF101C2B);

  /// Icon strokes, secondary labels.
  static const ink700 = Color(0xFF3B4A5C);

  /// Form labels.
  static const ink600 = Color(0xFF55657A);

  /// Body copy.
  static const ink500 = Color(0xFF5D6D80);

  /// Muted text.
  static const ink400 = Color(0xFF7A8A9C);

  /// Section eyebrows, chevrons, placeholders.
  static const ink300 = Color(0xFF9AA8B8);

  /// Inactive tab icon/label.
  static const ink250 = Color(0xFF8A98A8);

  /// Cards.
  static const surface = Color(0xFFFFFFFF);

  /// Screen background. One of only two background families in the design —
  /// the other is the brand blue. Nothing else is used.
  static const canvas = Color(0xFFF3F6FA);

  /// Card border (default).
  static const border = Color(0xFFE7EDF4);

  /// Input border.
  static const borderStrong = Color(0xFFE3E9F1);

  /// Row dividers.
  static const borderSoft = Color(0xFFEFF3F8);

  /// Debug panel border.
  static const borderDashed = Color(0xFFD3DEEA);

  /// Unread notification card border — stronger than a read card's.
  static const borderUnread = Color(0xFFDCE8F5);

  static const toggleOff = Color(0xFFDFE6EE);

  /// Weekend bars in the week strip.
  static const barMuted = Color(0xFFEAEFF5);

  /// Announcement card base, under the cover image.
  static const announcementBase = Color(0xFF123B5E);

  /// The hero card's 158-degree gradient. Flutter has no direct degree API, so
  /// the begin/end alignments below are that angle across the card's box.
  static const heroGradient = LinearGradient(
    begin: Alignment(-0.72, -1),
    end: Alignment(0.72, 1),
    colors: [brand500, brand700],
  );

  // --------------------------------------------------------------- radius ---

  static const rHero = 28.0;
  static const rCard = 24.0;
  static const rRow = 20.0;
  static const rButton = 18.0;
  static const rInput = 16.0;
  static const rChip = 13.0;
  static const rPill = 999.0;

  // -------------------------------------------------------------- spacing ---

  /// Screen horizontal padding.
  static const screenX = 20.0;

  /// Vertical gap between top-level blocks on a screen.
  static const blockGap = 18.0;

  // --------------------------------------------------------------- shadow ---

  static const heroShadow = [
    BoxShadow(
      color: Color(0xE60E5FA4), // rgba(14,95,164,.9)
      blurRadius: 40,
      spreadRadius: -26,
      offset: Offset(0, 22),
    ),
  ];

  /// White CTA sitting on the blue hero card.
  static const ctaShadow = [
    BoxShadow(
      color: Color(0x99000000), // rgba(0,0,0,.6)
      blurRadius: 22,
      spreadRadius: -14,
      offset: Offset(0, 10),
    ),
  ];

  static const primaryButtonShadow = [
    BoxShadow(
      color: Color(0xD90E5FA4), // rgba(14,95,164,.85)
      blurRadius: 24,
      spreadRadius: -12,
      offset: Offset(0, 12),
    ),
  ];

  static const unreadShadow = [
    BoxShadow(
      color: Color(0x1F101C2B), // rgba(16,28,43,.12)
      blurRadius: 8,
      spreadRadius: -4,
      offset: Offset(0, 2),
    ),
  ];

  // --------------------------------------------------------------- motion ---

  /// Hero card entry: opacity 0 to 1, translateY 10 to 0.
  static const riseIn = Duration(milliseconds: 350);

  /// Tab and chip state changes.
  static const stateChange = Duration(milliseconds: 180);

  /// Nav item.
  static const navChange = Duration(milliseconds: 150);

  // ------------------------------------------------------------- responsive --

  /// Content is capped and centred on tablets; phones are unaffected.
  static const maxContentWidth = 520.0;
}
