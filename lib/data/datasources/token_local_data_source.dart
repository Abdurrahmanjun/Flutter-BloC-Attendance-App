import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenLocalDataSource {
  Future<Unit> setToken({required String value});
  Future<String?> getToken();
}

class TokenLocalDataSourceImpl implements TokenLocalDataSource {
  final SharedPreferences sharedPreferences;

  TokenLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Unit> setToken({required String value}) {
    sharedPreferences.setString("token", value);
    return Future.value(unit);
  }

  @override
  Future<String?> getToken() async {
    final value = sharedPreferences.getString("token");
    return value;
  }
}
