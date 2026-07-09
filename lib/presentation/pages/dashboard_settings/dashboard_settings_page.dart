import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/presentation/bloc/token/token_bloc.dart';
import 'package:attendance/presentation/pages/auth/login_page.dart';
import 'package:attendance/presentation/pages/dashboard_settings/components/dev_prefer_menu.dart';

class DashboardSettingsPage extends StatefulWidget {
  const DashboardSettingsPage({super.key});

  @override
  State<DashboardSettingsPage> createState() => _DashboardSettingsPageState();
}

class _DashboardSettingsPageState extends State<DashboardSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Settings",
        color: context.scaffoldBackgroundColor,
        elevation: 0,
        showBack: false,
      ),
      body: BlocListener<TokenBloc, TokenState>(
        listener: (context, state) {
          if (state is LoggedOutState) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
              onTap: () => _confirmLogout(context),
            ),
            const DevPreferMenu(),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              BlocProvider.of<TokenBloc>(context).add(LogoutEvent());
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: navyDark),
            ),
          ),
        ],
      ),
    );
  }
}
