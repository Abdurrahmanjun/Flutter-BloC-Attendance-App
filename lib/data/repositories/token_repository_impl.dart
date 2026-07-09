import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:attendance/common/error/exceptions.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:dartz/dartz.dart';
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
    // LOCAL-ONLY LOGIN: the remote auth API is not available yet, so we treat a
    // login as a local flag — persist a session token so the app knows the user
    // is logged in. When the real API is ready, restore the remote call below.
    //
    //   final account =
    //       await remoteDataSource.login(username: username, password: password);
    //   final token = account.data!.accessToken!;
    try {
      final token = 'local-session:$username';
      await localDataSource.setToken(value: token);
      return Right(token);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getToken() async {
    final String? result = await localDataSource.getToken();
    if (result == null) {
      return Left(EmptyCacheFailure());
    }

    // A real JWT carries its own expiry; a local-session flag does not, so only
    // apply the expiry check when the stored value is actually a JWT.
    try {
      if (JwtDecoder.isExpired(result)) {
        return Left(ServerFailure());
      }
    } on FormatException {
      // Not a JWT (local-session flag) — treat as a valid, non-expiring token.
    }
    return Right(result);
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await localDataSource.clearToken();
    return const Right(unit);
  }
}
