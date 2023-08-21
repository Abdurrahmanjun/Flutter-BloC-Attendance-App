import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, String>> setOnboarding();
  Future<Either<Failure, String>> getOnboarding();
}
