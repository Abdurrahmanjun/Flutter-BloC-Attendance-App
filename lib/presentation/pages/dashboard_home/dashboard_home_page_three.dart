// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/presentation/bloc/attendance/summary_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/attendance_action_card.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/hrm_diagram_card.dart';

class DashboardHomePageThree extends StatefulWidget {
  const DashboardHomePageThree({super.key});

  @override
  State<DashboardHomePageThree> createState() => _DashboardHomePageThreeState();
}

class _DashboardHomePageThreeState extends State<DashboardHomePageThree> {
  @override
  void initState() {
    super.initState();
    context.read<TodayBloc>().add(LoadTodayEvent());
    context
        .read<SummaryBloc>()
        .add(LoadSummaryEvent(SummaryBloc.currentMonth()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: navylight,
        flexibleSpace: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Hello Abdurrahmanjun",
                  style: nbutils.boldTextStyle(size: 18, color: white),
                ),
                Text(
                  "Selamat Pagi, Selamat Beraktivitas !",
                  style:
                      nbutils.secondaryTextStyle(color: nearlyWhite, size: 12),
                )
              ],
            ),
          ),
        ),
        actions: [
          Container(
            height: 50.0,
            width: 50.0,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "https://images.pexels.com/photos/5110839/pexels-photo-5110839.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.all(Radius.circular(100.0))),
          ).paddingAll(16),
        ],
      ),
      body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              colors: [navylight, navylight],
            ),
          ),
          child: SingleChildScrollView(
              child: SizedBox(
            child: Column(
              children: <Widget>[
                const AttendanceActionCard(),
                // Others Menu
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _MenuItem(icon: Icons.date_range, title: "Overtime"),
                    _MenuItem(icon: Icons.date_range, title: "Sick Leave"),
                    _MenuItem(icon: Icons.date_range, title: "Reimburs"),
                    _MenuItem(icon: Icons.date_range, title: "Terlambat"),
                  ],
                ).paddingOnly(left: 16, right: 16, top: 8, bottom: 20),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 4),
                        child: _HrmTextSection(title: "Laporan Kehadiran"),
                      ),
                      HrmDiagramCard(),
                      SizedBox(height: 16),
                    ],
                  ),
                )
              ],
            ),
          ))),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData? icon;
  final String? title;
  const _MenuItem({
    Key? key,
    this.icon,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
              color: Color.fromRGBO(243, 245, 248, 1),
              borderRadius: BorderRadius.all(Radius.circular(18))),
          padding: const EdgeInsets.all(16),
          child: Icon(
            icon,
            color: Colors.blue[900],
            size: 30,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Text(
          '$title',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.blue[100]),
        ),
      ],
    );
  }
}

class _HrmTextSection extends StatelessWidget {
  final String? title;
  const _HrmTextSection({
    Key? key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "$title",
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Colors.black45,
      ),
    );
  }
}
