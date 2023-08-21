import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/domain/repositories/token_repository.dart';

class SetTokenUseCase {
  final TokenRepository repository;

  SetTokenUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String username,
    required String password,
  }) async {
    return await repository.setToken(
      username: username,
      password: password,
    );
  }
}
