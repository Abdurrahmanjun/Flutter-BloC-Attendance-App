import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/destination/destination.dart';
import 'package:attendance/domain/repositories/destination_repository.dart';

class SetDestinationUseCase {
  final DestinationRepository repository;

  SetDestinationUseCase(this.repository);

  Future<Either<Failure, List<Destination>>> call(String token) async {
    return await repository.setDestination(token: token);
  }
}
