// BASE URL
import 'dart:ui';

/// Override with `flutter run --dart-define=BASE_URL=http://localhost:4100`.
const mBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:4100',
);
const mFirebaseUrl = 'https://qr-menu-laravel.web.app';

class AppThemeMode {
  static const ThemeModeLight = 1;
  static const ThemeModeDark = 2;
  static const ThemeModeSystem = 0;
}

List<OnBoarding> onboardingImagePaths = [
  OnBoarding(
      imageUrl: "assets/images/onboarding-1.png",
      title: "Banyak Tempat Wisata",
      subtitle:
          "Kami menyediakan berbagai pilihan wisata untuk kamu yang suka jalan-jalan"),
  OnBoarding(
      imageUrl: "assets/images/onboarding-2.png",
      title: "Bepergian Mudah",
      subtitle:
          "Dengan aplikasi ini kamu akan sangat mudah mencatat kehadiran"),
];

// MODEL
class OnBoarding {
  final String imageUrl;
  final String title;
  final String subtitle;

  OnBoarding({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
