import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/destination/destination.dart';
import 'package:attendance/domain/repositories/destination_repository.dart';

class GetLastDestinationUseCase {
  final DestinationRepository repository;

  GetLastDestinationUseCase(this.repository);

  Future<Either<Failure, List<Destination>>> call() async {
    return await repository.getLastDestination();
  }
}
