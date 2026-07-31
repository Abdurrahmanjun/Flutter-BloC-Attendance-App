import 'package:dio/dio.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:attendance/common/settings/app_settings.dart';
import 'package:attendance/common/utils/constants.dart';
import 'package:attendance/common/utils/model_keys.dart';
import 'package:attendance/common/location/location_service.dart';
import 'package:attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:attendance/data/datasources/onboarding_local_data_source.dart';
import 'package:attendance/data/datasources/profile_remote_data_source.dart';
import 'package:attendance/data/datasources/token_local_data_source.dart';
import 'package:attendance/data/datasources/token_remote_data_source.dart';
import 'package:attendance/data/repositories/attendance_repository_impl.dart';
import 'package:attendance/data/repositories/onboarding_repository_impl.dart';
import 'package:attendance/data/repositories/profile_repository_impl.dart';
import 'package:attendance/data/repositories/token_repository_impl.dart';
import 'package:attendance/domain/repositories/attendance_repository.dart';
import 'package:attendance/domain/repositories/onboarding_repository.dart';
import 'package:attendance/domain/repositories/profile_repository.dart';
import 'package:attendance/domain/repositories/token_repository.dart';
import 'package:attendance/domain/usecases/attendance_use_cases.dart';
import 'package:attendance/domain/usecases/get_onboarding_use_case.dart';
import 'package:attendance/domain/usecases/profile_use_cases.dart';
import 'package:attendance/domain/usecases/get_token_use_case.dart';
import 'package:attendance/domain/usecases/logout_use_case.dart';
import 'package:attendance/domain/usecases/set_onboarding_use_case.dart';
import 'package:attendance/domain/usecases/set_token_use_case.dart';
import 'package:attendance/presentation/bloc/announcement/announcement_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/history_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/summary_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';
import 'package:attendance/presentation/bloc/notification/notification_bloc.dart';
import 'package:attendance/presentation/bloc/office/office_bloc.dart';
import 'package:attendance/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:attendance/presentation/bloc/profile_detail/profile_detail_bloc.dart';
import 'package:attendance/presentation/bloc/report/report_bloc.dart';
import 'package:attendance/presentation/bloc/profile/profile_bloc.dart';
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

  sl.registerFactory(() => OnboardingBloc(
        setOnboardingUseCase: sl(),
        getOnboardingUseCase: sl(),
      ));

  sl.registerFactory(() => TodayBloc(
        getTodayAttendanceUseCase: sl(),
        checkInUseCase: sl(),
        checkOutUseCase: sl(),
      ));
  sl.registerFactory(() => HistoryBloc(getAttendanceHistoryUseCase: sl()));
  sl.registerFactory(() => SummaryBloc(getAttendanceSummaryUseCase: sl()));
  sl.registerFactory(() => ReportBloc(
        getAttendanceSummaryUseCase: sl(),
        getAttendanceHistoryUseCase: sl(),
        getLeaveBalanceUseCase: sl(),
      ));

  sl.registerFactory(() => ProfileBloc(getMeUseCase: sl()));
  sl.registerFactory(() => ProfileDetailBloc(
        getMeUseCase: sl(),
        getLeaveBalanceUseCase: sl(),
        getOfficesUseCase: sl(),
        getAttendanceSummaryUseCase: sl(),
      ));
  sl.registerFactory(() => NotificationBloc(
        getNotificationsUseCase: sl(),
        markNotificationReadUseCase: sl(),
      ));
  sl.registerFactory(() => AnnouncementBloc(getAnnouncementsUseCase: sl()));
  sl.registerFactory(() => OfficeBloc(
        getOfficesUseCase: sl(),
        locationService: sl(),
      ));

// Usecases
  sl.registerLazySingleton(() => SetTokenUseCase(sl()));
  sl.registerLazySingleton(() => GetTokenUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => SetOnboardingUseCase(sl()));
  sl.registerLazySingleton(() => GetOnboardingUseCase(sl()));

  sl.registerLazySingleton(() => GetTodayAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => CheckInUseCase(sl()));
  sl.registerLazySingleton(() => CheckOutUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetLeaveBalanceUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceSummaryUseCase(sl()));

  sl.registerLazySingleton(() => GetMeUseCase(sl()));
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkNotificationReadUseCase(sl()));
  sl.registerLazySingleton(() => GetAnnouncementsUseCase(sl()));
  sl.registerLazySingleton(() => GetOfficesUseCase(sl()));

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

  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl(),
      locationService: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

// Datasources
  sl.registerLazySingleton<TokenRemoteDataSource>(
      () => TokenRemoteDataSourceImpl(dio: sl()));

  sl.registerLazySingleton<TokenLocalDataSource>(
      () => TokenLocalDataSourceImpl(sharedPreferences: sl()));

  sl.registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(
            sharedPreferences: sl(),
          ));

  sl.registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(dio: sl()));

  sl.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(dio: sl()));

// Core
  sl.registerLazySingleton<NetWorkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<LocationService>(() => GeolocatorLocationService());

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
  sl.registerLazySingleton(() => AppSettings(sl()));
}
