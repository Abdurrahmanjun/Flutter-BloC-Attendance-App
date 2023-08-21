import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/data/models/destination/destination.dart';

abstract class DestinationRepository {
  Future<Either<Failure, List<Destination>>> setDestination({
    required String token,
  });
  Future<Either<Failure, List<Destination>>> getDestination();
  Future<Either<Failure, bool>> setLastDestination({
    required Destination destination,
  });
  Future<Either<Failure, List<Destination>>> getLastDestination();
}
