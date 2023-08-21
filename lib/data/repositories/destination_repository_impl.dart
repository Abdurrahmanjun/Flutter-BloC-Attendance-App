import 'package:otaqu/common/error/exceptions.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:otaqu/common/network/network_info.dart';
import 'package:otaqu/data/datasources/destination_local_data_source.dart';
import 'package:otaqu/data/datasources/destination_remote_data_source.dart';
import 'package:otaqu/data/models/destination/destination.dart';
import 'package:otaqu/domain/repositories/destination_repository.dart';

class DestinationRepositoryImpl implements DestinationRepository {
  final DestinationRemoteDataSource remoteDataSource;
  final DestinationLocalDataSource localDataSource;
  final NetWorkInfo netWorkInfo;

  DestinationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.netWorkInfo,
  });

  @override
  Future<Either<Failure, List<Destination>>> setDestination(
      {required String token}) async {
    if (await netWorkInfo.isConnected) {
      try {
        final destinations =
            await remoteDataSource.getDestination(token: token);

        for (var element in destinations) {
          if (element.typeSource!.contains("location")) {
            await localDataSource.insertDestination(element);
          }
        }

        return Right(destinations);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Destination>>> getDestination() async {
    final result = await localDataSource.getListDestination();
    if (result.isNotEmpty) {
      return Right(result);
    } else {
      return Left(EmptyCacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> setLastDestination(
      {required Destination destination}) async {
    try {
      final data = await localDataSource.getLastListDestination();

      if (data.isNotEmpty) {
        final sameData = data
            .where(
                (element) => element.destinationId == destination.destinationId)
            .toList();

        if (sameData.isEmpty) {
          await localDataSource.insertLastDestination(destination);
        } else {
          await localDataSource.deleteLastDestination(destination).then(
              (value) => localDataSource.insertLastDestination(destination));
        }
      } else {
        await localDataSource.insertLastDestination(destination);
      }

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Destination>>> getLastDestination() async {
    final result = await localDataSource.getLastListDestination();
    if (result.isNotEmpty) {
      final reversed = result.reversed.toList();
      return Right(reversed);
    } else {
      return Left(EmptyCacheFailure());
    }
  }
}
