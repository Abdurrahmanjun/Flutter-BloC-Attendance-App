import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/domain/repositories/token_repository.dart';

class GetTokenUseCase {
  final TokenRepository repository;

  GetTokenUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.getToken();
  }
}
