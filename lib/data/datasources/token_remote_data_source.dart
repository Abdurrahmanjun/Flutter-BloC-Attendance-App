import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:otaqu/data/models/login/base_login.dart';

abstract class TokenRemoteDataSource {
  Future<BaseLogin> login({
    required String username,
    required String password,
  });
}

class TokenRemoteDataSourceImpl implements TokenRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  TokenRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<BaseLogin> login({
    required String username,
    required String password,
  }) async {
    String url = "$baseUrl/utilization/api/auth/login";
    Map<String, String> body = {
      "username": username,
      "password": password,
    };

    var response = await dio.postUri(
      Uri.parse(url),
      data: json.encode(body),
    );

    var result = BaseLogin.fromJson(response.data);
    return result;
  }
}
