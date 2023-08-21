import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/data/models/destination/destination.dart';
import 'package:otaqu/domain/repositories/destination_repository.dart';

class SetLastDestinationUseCase {
  final DestinationRepository repository;

  SetLastDestinationUseCase(this.repository);

  Future<Either<Failure, bool>> call({required Destination destination}) async {
    return await repository.setLastDestination(destination: destination);
  }
}
