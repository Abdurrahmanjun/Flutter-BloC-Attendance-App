import 'package:otaqu/common/error/exceptions.dart';
import 'package:otaqu/common/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:otaqu/data/datasources/onboarding_local_data_source.dart';
import 'package:otaqu/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, String>> setOnboarding() async {
    try {
      await localDataSource.setOnboarding();
      return const Right("");
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> getOnboarding() async {
    final result = await localDataSource.getOnboarding();
    if (result != null) {
      return const Right("");
    } else {
      return Left(EmptyCacheFailure());
    }
  }
}
