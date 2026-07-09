import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/presentation/bloc/destination/destination_bloc.dart';
import 'package:attendance/presentation/bloc/token/token_bloc.dart';
import 'package:attendance/presentation/pages/auth/components/forgot_password_dialog.dart';
import 'package:attendance/presentation/pages/dashboard_navigation/dashboard_navigation_page.dart';
import 'package:attendance/common/utils/style_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nikController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final username = _nikController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NIK dan Kata Sandi wajib diisi.'),
          backgroundColor: Colors.redAccent,
          margin: EdgeInsets.all(8),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    BlocProvider.of<TokenBloc>(context)
        .add(SetTokenEvent(username: username, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TokenBloc, TokenState>(
        listener: (context, state) {
          if (state is LoadedGetTokenState) {
            // Token persisted = "already logged in" flag. Preload dashboard
            // data, then move on to the dashboard.
            BlocProvider.of<DestinationBloc>(context)
                .add(GetDestinationEvent(token: state.token));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeNavBarPage()),
            );
          }

          if (state is ErrorGetTokenState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                margin: const EdgeInsets.all(8),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [navylight, navylight],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              128.height,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Selamat Datang",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  ),
                  10.height,
                  const Text(
                    "Masukan NIK & Kata sandi yang benar \nuntuk masuk ke akun kamu",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ).paddingAll(20),
              10.height,
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        32.height,
                        _NikInput(controller: _nikController),
                        16.height,
                        _PasswordInput(controller: _passwordController),
                        32.height,
                        BlocBuilder<TokenBloc, TokenState>(
                          builder: (context, state) {
                            final isLoading = state is LoadingGetTokenState;
                            return GestureDetector(
                              onTap: isLoading ? null : _login,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: navyDark),
                                child: Center(
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          "LOGIN",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),
                            );
                          },
                        ),
                        32.height,
                        TextButton(
                          onPressed: () {
                            showInDialog(
                              context,
                              dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                              builder: (_) => ForgotPasswordDialog(),
                            );
                          },
                          child: Text(
                            'FORGOT PASSWORD?',
                            style: primaryTextStyle(
                              color: Colors.grey,
                              weight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ).paddingAll(32),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _NikInput extends StatelessWidget {
  final TextEditingController controller;

  const _NikInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: Column(
        children: <Widget>[
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "NIK ( Nomor Induk Karyawan )",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ).paddingOnly(left: 16, right: 16),
        ],
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const _PasswordInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: Column(
        children: <Widget>[
          TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "Kata Sandi",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ).paddingOnly(left: 16, right: 16),
        ],
      ),
    );
  }
}
