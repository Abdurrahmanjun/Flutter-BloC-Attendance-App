import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/data/models/destination/destination.dart';
import 'package:otaqu/domain/repositories/destination_repository.dart';

class GetDestinationUseCase {
  final DestinationRepository repository;

  GetDestinationUseCase(this.repository);

  Future<Either<Failure, List<Destination>>> call() async {
    return await repository.getDestination();
  }
}
