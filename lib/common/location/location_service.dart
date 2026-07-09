import 'package:geolocator/geolocator.dart';

/// Thrown when a fix cannot be taken. [message] is safe to show.
class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => message;
}

/// Both punches need a `lat`/`lng`, and the server rejects a check-in outside
/// the office geofence — so a fix is a hard prerequisite, not a nicety.
abstract class LocationService {
  Future<Position> currentPosition();

  /// Metres between two points, for the local geofence affordance.
  double distanceBetween(double lat1, double lng1, double lat2, double lng2);
}

class GeolocatorLocationService implements LocationService {
  @override
  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
          'Layanan lokasi mati. Aktifkan untuk melakukan absensi.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Izin lokasi ditolak.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Izin lokasi ditolak permanen. Ubah di Pengaturan.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  @override
  double distanceBetween(
          double lat1, double lng1, double lat2, double lng2) =>
      Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
}
