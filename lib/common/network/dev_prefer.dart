import 'package:flutter/foundation.dart';

/// A `Prefer` header value the debug dev menu can set at runtime.
///
/// Prism is a stateless mock: a `POST /attendance/check-in` does not make the
/// next `GET /attendance/today` return `checked_in`. `Prefer` is how you pick
/// which example or status code it replays, which is the only way to walk the
/// whole day — including the geofence rejection — from inside the app with no
/// backend. Ignored entirely outside debug builds.
class DevPrefer {
  DevPrefer._();

  /// e.g. `example=afterLateCheckIn`, or `code=422`. Null sends no header.
  static final ValueNotifier<String?> today = ValueNotifier<String?>(null);
  static final ValueNotifier<String?> punch = ValueNotifier<String?>(null);

  /// Which value applies to a given request path. `today` and the punch
  /// endpoints are driven independently: you want `today` pinned to
  /// `afterLateCheckIn` while check-out returns its 200, for instance.
  static String? forPath(String path) {
    if (path.contains('/attendance/today')) return today.value;
    if (path.contains('/attendance/check-in') ||
        path.contains('/attendance/check-out')) {
      return punch.value;
    }
    return null;
  }

  static const todayOptions = <String, String?>{
    'Live (not_checked_in)': null,
    'After late check-in': 'example=afterLateCheckIn',
    'After check-out': 'example=afterCheckOut',
  };

  static const punchOptions = <String, String?>{
    'Success': null,
    '409 already checked in': 'code=409',
    '422 outside geofence': 'code=422',
  };
}
