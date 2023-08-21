import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/data/models/destination/destination.dart';
import 'package:otaqu/domain/repositories/destination_repository.dart';

class SetDestinationUseCase {
  final DestinationRepository repository;

  SetDestinationUseCase(this.repository);

  Future<Either<Failure, List<Destination>>> call(String token) async {
    return await repository.setDestination(token: token);
  }
}
