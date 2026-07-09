import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/domain/repositories/onboarding_repository.dart';

class GetOnboardingUseCase {
  final OnboardingRepository repository;

  GetOnboardingUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.getOnboarding();
  }
}
