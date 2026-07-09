import 'package:dartz/dartz.dart';
import 'package:attendance/common/error/failures.dart';
import 'package:attendance/domain/repositories/onboarding_repository.dart';

class SetOnboardingUseCase {
  final OnboardingRepository repository;

  SetOnboardingUseCase(this.repository);

  Future<Either<Failure, String>> call() async {
    return await repository.setOnboarding();
  }
}
