import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardNotificationPage extends StatefulWidget {
  const DashboardNotificationPage({super.key});

  @override
  State<DashboardNotificationPage> createState() =>
      _DashboardNotificationPageState();
}

class _DashboardNotificationPageState extends State<DashboardNotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Notification",
        color: context.scaffoldBackgroundColor,
        elevation: 0,
        showBack: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Notifications List',
            ),
          ],
        ),
      ),
    );
  }
}
