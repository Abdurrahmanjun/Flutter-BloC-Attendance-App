import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/common/utils/design_tokens.dart';

class AppTheme {
  AppTheme._();

  /// Applies `tabular-nums` to a style. The design calls for it on every time,
  /// duration, and currency value, so digits line up between rows.
  static TextStyle numeric(TextStyle style) =>
      style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

  /// Brand blue behind white status-bar content — Login and Profil.
  static const brandOverlay = SystemUiOverlayStyle(
    statusBarColor: T.brand600,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  /// Canvas behind dark status-bar content — every other screen.
  static const canvasOverlay = SystemUiOverlayStyle(
    statusBarColor: T.canvas,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  );

  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme(
      primary: T.brand600,
      primaryContainer: createMaterialColor(T.brand600),
      secondary: T.accent500,
      secondaryContainer: createMaterialColor(T.accent500),
      surface: T.surface,
      background: T.canvas,
      error: T.danger500,
      onPrimary: Colors.white,
      onSecondary: T.accentOnFill,
      // `surface` is white, so `onSurface` cannot be. ListTile, and anything
      // else that takes its foreground from the scheme, rendered white-on-white
      // and was simply invisible.
      onSurface: T.ink900,
      onBackground: T.ink900,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: T.canvas,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    bottomNavigationBarTheme:
        const BottomNavigationBarThemeData(backgroundColor: Colors.white),
    iconTheme: const IconThemeData(color: T.ink700),
    textTheme: GoogleFonts.plusJakartaSansTextTheme()
        .apply(bodyColor: T.ink900, displayColor: T.ink900),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: T.ink300,
    dividerColor: T.borderSoft,
    cardColor: T.surface,
    dialogTheme: DialogThemeData(shape: dialogShape()),
    appBarTheme: const AppBarTheme(systemOverlayStyle: canvasOverlay),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(T.brand600),
      overlayColor: MaterialStateProperty.all(T.brand100),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(T.brand600),
      overlayColor: MaterialStateProperty.all(T.brand100),
    ),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  /// The redesign specifies light only — "Mode gelap" is a Pengaturan toggle
  /// that is off, and no dark tokens were handed off. This theme is kept for
  /// that switch to grow into; `main.dart` pins the app to light until then.
  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme(
      primary: Colors.white,
      primaryContainer: createMaterialColor(Colors.white),
      secondary: Colors.white,
      secondaryContainer: createMaterialColor(Colors.white),
      surface: scaffoldColorDark,
      background: scaffoldColorDark,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.black,
      onError: Colors.redAccent,
      brightness: Brightness.light,
    ),
    primaryColor: T.brand600,
    scaffoldBackgroundColor: scaffoldColorDark,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
    dialogBackgroundColor: scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white12,
    cardColor: scaffoldSecondaryDark,
    dialogTheme: DialogThemeData(shape: dialogShape()),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(Colors.white),
      checkColor: MaterialStateProperty.all(Colors.black),
      overlayColor: MaterialStateProperty.all(Color(0xFF5D5F6E)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(Colors.white),
      overlayColor: MaterialStateProperty.all(Color(0xFF5D5F6E)),
    ),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        statusBarColor: scaffoldColorDark,
      ),
    ),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
