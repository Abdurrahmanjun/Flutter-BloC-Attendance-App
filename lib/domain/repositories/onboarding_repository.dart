import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';

abstract class OnboardingRepository {
  Future<Either<Failure, String>> setOnboarding();
  Future<Either<Failure, String>> getOnboarding();
}
