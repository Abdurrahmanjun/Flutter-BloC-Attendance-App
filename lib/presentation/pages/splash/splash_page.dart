import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance/presentation/bloc/destination/destination_bloc.dart';
import 'package:attendance/presentation/bloc/token/token_bloc.dart';
import 'package:attendance/presentation/pages/auth/login_page.dart';
import 'package:attendance/presentation/pages/dashboard_navigation/dashboard_navigation_page.dart';

/// A lightweight routing gate. It shows nothing branded — just briefly waits
/// for the persisted-token check to resolve, then jumps straight to the login
/// screen or the dashboard. No artificial delay, so there is no visible
/// "second splash" after the native launch screen.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    // Handle the case where the token check already resolved before this
    // page mounted (BlocListener only fires on subsequent changes).
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  void _go(Widget page) {
    if (_navigated) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Routes once the token (login flag) check has finished. Onboarding is
  /// intentionally skipped for now (the page still exists for later use).
  void _decide() {
    if (_navigated) return;

    final tokenState = context.read<TokenBloc>().state;

    // Wait until the persisted-token check has finished.
    if (tokenState is TokenInitial || tokenState is LoadingGetTokenState) {
      return;
    }

    // Valid persisted token -> already logged in -> go to the dashboard.
    if (tokenState is LoadedGetTokenState) {
      BlocProvider.of<DestinationBloc>(context)
          .add(GetDestinationEvent(token: tokenState.token));
      _go(HomeNavBarPage());
      return;
    }

    // No token -> not logged in -> straight to login.
    _go(const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<TokenBloc, TokenState>(
        listener: (context, state) => _decide(),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
