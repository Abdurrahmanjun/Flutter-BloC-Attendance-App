import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<Unit> setOnboarding();
  Future<String?> getOnboarding();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<Unit> setOnboarding() {
    sharedPreferences.setString("onboarding", "save");
    return Future.value(unit);
  }

  @override
  Future<String?> getOnboarding() async {
    final value = sharedPreferences.getString("onboarding");
    return value;
  }
}
