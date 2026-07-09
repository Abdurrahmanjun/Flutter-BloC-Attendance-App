import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:attendance/common/network/dev_prefer.dart';
import 'package:attendance/data/datasources/token_local_data_source.dart';

/// Builds the single [Dio] every datasource shares: base URL from the
/// BASE_URL dart-define, a bearer token on every request, and — in debug
/// builds only — the `Prefer` header the Prism mock uses to select a response.
Dio buildDio({
  required String baseUrl,
  required TokenLocalDataSource tokenLocalDataSource,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.add(_AuthInterceptor(tokenLocalDataSource));
  if (kDebugMode) dio.interceptors.add(_PreferInterceptor());
  return dio;
}

class _AuthInterceptor extends Interceptor {
  final TokenLocalDataSource _tokens;

  _AuthInterceptor(this._tokens);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // /api/auth/login and /api/auth/refresh declare `security: []`; sending a
    // stale token with them would be meaningless at best.
    if (!options.path.startsWith('/api/auth/login') &&
        !options.path.startsWith('/api/auth/refresh')) {
      final token = await _tokens.getToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _PreferInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final prefer = DevPrefer.forPath(options.path);
    if (prefer != null) options.headers['Prefer'] = prefer;
    handler.next(options);
  }
}
