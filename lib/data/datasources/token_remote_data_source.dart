import 'package:dio/dio.dart';

import 'package:attendance/common/network/api_response.dart';
import 'package:attendance/data/models/auth/auth_token.dart';

abstract class TokenRemoteDataSource {
  /// Throws [DioException] on any non-2xx; the repository maps it to a Failure.
  Future<AuthToken> login({
    required String username,
    required String password,
  });
}

class TokenRemoteDataSourceImpl implements TokenRemoteDataSource {
  final Dio dio;

  TokenRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/auth/login',
      data: {'username': username, 'password': password},
    );

    final envelope = ApiResponse<AuthToken>.fromJson(
      response.data!,
      (data) => AuthToken.fromJson(data as Map<String, dynamic>),
    );

    final token = envelope.data;
    if (token == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: envelope.message,
      );
    }
    return token;
  }
}
