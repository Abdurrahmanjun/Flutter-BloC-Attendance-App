import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';

abstract class TokenRepository {
  Future<Either<Failure, String>> setToken({
    required String username,
    required String password,
  });
  Future<Either<Failure, String>> getToken();
  Future<Either<Failure, Unit>> logout();
}
