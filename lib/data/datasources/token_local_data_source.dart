import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenLocalDataSource {
  Future<Unit> setToken({required String value});
  Future<String?> getToken();

  /// Persisted for Stage 2's rotation flow. Nothing reads it yet.
  Future<Unit> setRefreshToken({required String value});
  Future<String?> getRefreshToken();

  Future<Unit> clearToken();
}

class TokenLocalDataSourceImpl implements TokenLocalDataSource {
  static const _tokenKey = 'token';
  static const _refreshTokenKey = 'refresh_token';

  final SharedPreferences sharedPreferences;

  TokenLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<Unit> setToken({required String value}) async {
    await sharedPreferences.setString(_tokenKey, value);
    return unit;
  }

  @override
  Future<String?> getToken() async => sharedPreferences.getString(_tokenKey);

  @override
  Future<Unit> setRefreshToken({required String value}) async {
    await sharedPreferences.setString(_refreshTokenKey, value);
    return unit;
  }

  @override
  Future<String?> getRefreshToken() async =>
      sharedPreferences.getString(_refreshTokenKey);

  @override
  Future<Unit> clearToken() async {
    await sharedPreferences.remove(_tokenKey);
    await sharedPreferences.remove(_refreshTokenKey);
    return unit;
  }
}
