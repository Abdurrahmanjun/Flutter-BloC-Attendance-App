import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/destination/destination.dart';
import 'package:attendance/domain/repositories/destination_repository.dart';

class SetLastDestinationUseCase {
  final DestinationRepository repository;

  SetLastDestinationUseCase(this.repository);

  Future<Either<Failure, bool>> call({required Destination destination}) async {
    return await repository.setLastDestination(destination: destination);
  }
}
