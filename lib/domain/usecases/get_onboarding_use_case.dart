import 'package:dartz/dartz.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:otaqu/domain/repositories/onboarding_repository.dart';

class GetOnboardingUseCase {
  final OnboardingRepository repository;

  GetOnboardingUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.getOnboarding();
  }
}
