import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:otaqu/common/error/exceptions.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:otaqu/common/network/network_info.dart';
import 'package:otaqu/data/datasources/token_local_data_source.dart';
import 'package:otaqu/data/datasources/token_remote_data_source.dart';
import 'package:otaqu/domain/repositories/token_repository.dart';

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
      final account = await remoteDataSource.login(
        username: username,
        password: password,
      );
      final token = account.data!.accessToken!;
      await localDataSource.setToken(value: token);
      return Right(token);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getToken() async {
    final String? result = await localDataSource.getToken();
    if (result != null) {
      final isExpired = JwtDecoder.isExpired(result);

      if (isExpired) {
        return Left(ServerFailure());
      } else {
        return Right(result);
      }
    } else {
      return Left(EmptyCacheFailure());
    }
  }
}
