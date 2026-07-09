import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/avail/base_avail.dart';
import 'package:attendance/domain/repositories/avail_repository.dart';

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
