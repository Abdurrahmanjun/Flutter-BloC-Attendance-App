import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardAbsencePage extends StatefulWidget {
  const DashboardAbsencePage({super.key});

  @override
  State<DashboardAbsencePage> createState() => _DashboardAbsencePageState();
}

class _DashboardAbsencePageState extends State<DashboardAbsencePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Absence",
        color: context.scaffoldBackgroundColor,
        elevation: 0,
        showBack: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Absences List',
            ),
          ],
        ),
      ),
    );
  }
}
