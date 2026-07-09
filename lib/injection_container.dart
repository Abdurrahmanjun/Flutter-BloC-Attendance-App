import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:attendance/common/utils/constants.dart';
import 'package:attendance/common/utils/model_keys.dart';
import 'package:attendance/data/datasources/onboarding_local_data_source.dart';
import 'package:attendance/data/datasources/token_local_data_source.dart';
import 'package:attendance/data/datasources/token_remote_data_source.dart';
import 'package:attendance/data/repositories/onboarding_repository_impl.dart';
import 'package:attendance/data/repositories/token_repository_impl.dart';
import 'package:attendance/domain/repositories/onboarding_repository.dart';
import 'package:attendance/domain/repositories/token_repository.dart';
import 'package:attendance/domain/usecases/get_onboarding_use_case.dart';
import 'package:attendance/domain/usecases/get_token_use_case.dart';
import 'package:attendance/domain/usecases/logout_use_case.dart';
import 'package:attendance/domain/usecases/set_onboarding_use_case.dart';
import 'package:attendance/domain/usecases/set_token_use_case.dart';
import 'package:attendance/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:attendance/presentation/bloc/promo/promo_bloc.dart';
import 'package:attendance/presentation/bloc/token/token_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/network/dio_client.dart';
import 'common/network/network_info.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
// Bloc
  sl.registerFactory(() => TokenBloc(
        setTokenUseCase: sl(),
        getTokenUseCase: sl(),
        logoutUseCase: sl(),
      ));

  sl.registerFactory(() => PromoBloc());
  sl.registerFactory(() => OnboardingBloc(
        setOnboardingUseCase: sl(),
        getOnboardingUseCase: sl(),
      ));

// Usecases
  sl.registerLazySingleton(() => SetTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SetOnboardingUseCase(sl()));
  sl.registerLazySingleton(() => GetOnboardingUseCase(sl()));

// Repository
  sl.registerLazySingleton<TokenRepository>(
    () => TokenRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      netWorkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(
      localDataSource: sl(),
    ),
  );

// Datasources
  sl.registerLazySingleton<TokenRemoteDataSource>(
      () => TokenRemoteDataSourceImpl(
            dio: sl(),
            baseUrl: sl(instanceName: InjectionInstance.base),
          ));

  sl.registerLazySingleton<TokenLocalDataSource>(
      () => TokenLocalDataSourceImpl(sharedPreferences: sl()));

  sl.registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(
            sharedPreferences: sl(),
          ));

// Core
  sl.registerLazySingleton<NetWorkInfo>(() => NetworkInfoImpl(sl()));

// External
  sl.registerLazySingleton<Dio>(() => buildDio(
        baseUrl: sl(instanceName: InjectionInstance.base),
        tokenLocalDataSource: sl(),
      ));
  sl.registerLazySingleton(() => InternetConnectionChecker());
  sl.registerLazySingleton<String>(() => mBaseUrl,
      instanceName: InjectionInstance.base);
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}
