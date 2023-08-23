import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otaqu/common/utils/colors.dart';
import 'package:otaqu/presentation/pages/auth/components/forgot_password_dialog.dart';
import 'package:otaqu/common/utils/style_widget.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      _NikInput(),
                      16.height,
                      _PasswordInput(),
                      32.height,
                      GestureDetector(
                        onTap: () {
                          var snackbar = const SnackBar(
                            content:
                                Text('Selamat, data berhasil ditambahkan.'),
                            backgroundColor: toastGreen,
                            margin: EdgeInsets.all(8),
                            behavior: SnackBarBehavior.floating,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackbar);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: navyDark),
                          child: const Center(
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
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
    );
  }
}

class _NikInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: Column(
        children: <Widget>[
          const TextField(
            decoration: InputDecoration(
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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: textFieldBoxDecoration,
      child: Column(
        children: <Widget>[
          const TextField(
            decoration: InputDecoration(
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
