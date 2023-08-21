import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/data/models/avail/base_avail.dart';
import 'package:otaqu/domain/repositories/avail_repository.dart';

class GetAvailUseCase {
  final AvailRepository repository;

  GetAvailUseCase(this.repository);

  Future<Either<Failure, BaseAvail>> call(
      {required String token, required int typeId}) async {
    return await repository.getAvail(
      token: token,
      typeId: typeId,
    );
  }
}
