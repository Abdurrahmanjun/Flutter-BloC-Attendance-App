import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance/app_theme.dart';
import 'package:attendance/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:attendance/presentation/bloc/promo/promo_bloc.dart';
import 'package:attendance/presentation/bloc/token/token_bloc.dart';
import 'package:attendance/presentation/pages/splash/splash_page.dart';
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
          create: (context) => di.sl<PromoBloc>(),
        ),
        BlocProvider(
          create: (context) =>
              di.sl<OnboardingBloc>()..add(GetOnBoardingEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Attendance',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const SplashPage(),
      ),
    );
  }
}
