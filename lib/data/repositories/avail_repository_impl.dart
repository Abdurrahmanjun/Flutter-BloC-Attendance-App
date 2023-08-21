import 'package:otaqu/common/error/exceptions.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:otaqu/common/network/network_info.dart';
import 'package:otaqu/data/datasources/avail_remote_data_source.dart';
import 'package:otaqu/data/models/avail/base_avail.dart';
import 'package:otaqu/domain/repositories/avail_repository.dart';

class AvailRepositoryImpl implements AvailRepository {
  final AvailRemoteDataSource remoteDataSource;
  final NetWorkInfo netWorkInfo;

  AvailRepositoryImpl({
    required this.remoteDataSource,
    required this.netWorkInfo,
  });

  @override
  Future<Either<Failure, BaseAvail>> getAvail(
      {required String token, required int typeId}) async {
    if (await netWorkInfo.isConnected) {
      try {
        final avails = await remoteDataSource.getAvail(
          token: token,
          typeId: typeId,
        );

        return Right(avails);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(ServerFailure());
    }
  }
}
