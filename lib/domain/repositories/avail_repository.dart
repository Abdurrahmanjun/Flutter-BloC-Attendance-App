import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/data/models/avail/base_avail.dart';

abstract class AvailRepository {
  Future<Either<Failure, BaseAvail>> getAvail({
    required String token,
    required int typeId,
  });
}
