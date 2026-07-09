import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otaqu/presentation/bloc/destination/destination_bloc.dart';
import 'package:otaqu/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:otaqu/presentation/bloc/token/token_bloc.dart';
import 'package:otaqu/presentation/pages/auth/login_page.dart';
import 'package:otaqu/presentation/pages/dashboard_navigation/dashboard_navigation_page.dart';
import 'package:otaqu/presentation/pages/onboarding/onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _navigated = false;

  void _go(Widget page) {
    if (_navigated) return;
    _navigated = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => page),
      );
    });
  }

  /// Decides where to go once the token (login flag) and onboarding states
  /// have both resolved.
  void _decide() {
    if (_navigated) return;

    final tokenState = context.read<TokenBloc>().state;

    // Wait until the persisted-token check has finished.
    if (tokenState is TokenInitial || tokenState is LoadingGetTokenState) {
      return;
    }

    // A valid persisted token means the user already logged in previously,
    // so skip the login screen and go straight to the dashboard.
    if (tokenState is LoadedGetTokenState) {
      BlocProvider.of<DestinationBloc>(context)
          .add(GetDestinationEvent(token: tokenState.token));
      _go(HomeNavBarPage());
      return;
    }

    // No token -> not logged in. First-time users see onboarding, returning
    // (but logged-out) users go straight to login.
    final onboardingState = context.read<OnboardingBloc>().state;
    if (onboardingState is LoadedGetOnboardingState) {
      _go(const LoginPage());
    } else if (onboardingState is ErrorGetOnboardingState) {
      _go(const OnBoardingPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: MultiBlocListener(
        listeners: [
          BlocListener<TokenBloc, TokenState>(
            listener: (context, state) => _decide(),
          ),
          BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) => _decide(),
          ),
        ],
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 200,
              ),
              20.height,
              const Text("Powered by : HRM App")
            ],
          ),
        ),
      ),
    );
  }
}
