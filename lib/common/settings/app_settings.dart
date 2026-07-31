import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Pengaturan switches, persisted locally.
///
/// None of these is server state — the contract has no preferences endpoint —
/// so they live in `SharedPreferences` and are exposed as [ValueNotifier]s so
/// the screen and anything that reads them stay in step without a bloc.
class AppSettings {
  static const _checkInReminderKey = 'pref_check_in_reminder';
  static const _locationOnCheckInKey = 'pref_location_on_check_in';
  static const _rememberNikKey = 'pref_remember_nik';
  static const _savedNikKey = 'pref_saved_nik';

  final SharedPreferences _prefs;

  /// Both default on, as the design ships them.
  late final ValueNotifier<bool> checkInReminder =
      ValueNotifier(_prefs.getBool(_checkInReminderKey) ?? true);

  /// Gates the home screen's geofence polling. It does **not** stop location
  /// being sent with a punch — the contract requires `lat`/`lng` on both
  /// punches, so turning this off would break check-in entirely rather than
  /// make it more private.
  late final ValueNotifier<bool> locationOnCheckIn =
      ValueNotifier(_prefs.getBool(_locationOnCheckInKey) ?? true);

  AppSettings(this._prefs);

  Future<void> setCheckInReminder(bool value) async {
    checkInReminder.value = value;
    await _prefs.setBool(_checkInReminderKey, value);
  }

  Future<void> setLocationOnCheckIn(bool value) async {
    locationOnCheckIn.value = value;
    await _prefs.setBool(_locationOnCheckInKey, value);
  }

  /// "Ingat saya" on the login screen. Only the NIK is kept — never the
  /// password, which belongs nowhere but the login request.
  bool get rememberNik => _prefs.getBool(_rememberNikKey) ?? false;

  String? get savedNik => rememberNik ? _prefs.getString(_savedNikKey) : null;

  Future<void> setRememberNik({required bool remember, String? nik}) async {
    await _prefs.setBool(_rememberNikKey, remember);
    if (remember && nik != null && nik.isNotEmpty) {
      await _prefs.setString(_savedNikKey, nik);
    } else if (!remember) {
      await _prefs.remove(_savedNikKey);
    }
  }
}
