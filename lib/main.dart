import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otaqu/app_theme.dart';
import 'package:otaqu/presentation/bloc/avail/avail_bloc.dart';
import 'package:otaqu/presentation/bloc/destination/destination_bloc.dart';
import 'package:otaqu/presentation/bloc/last_destination/last_destination_bloc.dart';
import 'package:otaqu/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:otaqu/presentation/bloc/promo/promo_bloc.dart';
import 'package:otaqu/presentation/bloc/token/token_bloc.dart';
import 'package:otaqu/presentation/pages/splash/splash_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => di.sl<TokenBloc>()..add(GetTokenEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<DestinationBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<LastDestinationBloc>()..add(GetLastDestinationEvent()),
        ),
        BlocProvider(
          create: (context) => di.sl<PromoBloc>(),
        ),
        BlocProvider(
          create: (context) => di.sl<AvailBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<OnboardingBloc>()..add(GetOnBoardingEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Otaqu',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashPage(),
      ),
    );
  }
}
