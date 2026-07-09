import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/domain/repositories/token_repository.dart';

class LogoutUseCase {
  final TokenRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.logout();
  }
}
