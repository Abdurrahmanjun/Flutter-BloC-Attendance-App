import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/data/models/avail/base_avail.dart';

abstract class AvailRepository {
  Future<Either<Failure, BaseAvail>> getAvail({
    required String token,
    required int typeId,
  });
}
