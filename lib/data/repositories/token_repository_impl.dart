import 'package:dartz/dartz.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:attendance/common/error/error_mapper.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/common/network/network_info.dart';
import 'package:attendance/data/datasources/token_local_data_source.dart';
import 'package:attendance/data/datasources/token_remote_data_source.dart';
import 'package:attendance/domain/repositories/token_repository.dart';

class TokenRepositoryImpl implements TokenRepository {
  final TokenRemoteDataSource remoteDataSource;
  final TokenLocalDataSource localDataSource;
  final NetWorkInfo netWorkInfo;

  TokenRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.netWorkInfo,
  });

  @override
  Future<Either<Failure, String>> setToken({
    required String username,
    required String password,
  }) async {
    try {
      final auth = await remoteDataSource.login(
        username: username,
        password: password,
      );

      await localDataSource.setToken(value: auth.accessToken);
      final refreshToken = auth.refreshToken;
      if (refreshToken != null) {
        // Persisted only; rotation is Stage 2.
        await localDataSource.setRefreshToken(value: refreshToken);
      }

      return Right(auth.accessToken);
    } catch (error) {
      return Left(mapError(error));
    }
  }

  @override
  Future<Either<Failure, String>> getToken() async {
    final String? result = await localDataSource.getToken();
    if (result == null) {
      return const Left(EmptyCacheFailure());
    }

    // The contract's bearerAuth scheme promises a real `exp` claim so the
    // client can pre-empt expiry rather than waiting for a 401.
    try {
      if (JwtDecoder.isExpired(result)) {
        await localDataSource.clearToken();
        return const Left(UnauthorizedFailure());
      }
    } on FormatException {
      // Not a JWT at all — unusable, so drop it rather than trust it forever.
      await localDataSource.clearToken();
      return const Left(UnauthorizedFailure());
    }
    return Right(result);
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await localDataSource.clearToken();
    return const Right(unit);
  }
}
