// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;

import 'package:cached_network_image/cached_network_image.dart';

import 'package:attendance/common/utils/colors.dart';
import 'package:attendance/presentation/bloc/announcement/announcement_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/summary_bloc.dart';
import 'package:attendance/presentation/bloc/attendance/today_bloc.dart';
import 'package:attendance/presentation/bloc/office/office_bloc.dart';
import 'package:attendance/presentation/bloc/profile/profile_bloc.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/announcement_carousel.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/attendance_action_card.dart';
import 'package:attendance/presentation/pages/dashboard_home/components/hrm_diagram_card.dart';
import 'package:attendance/presentation/pages/profile/profile_page.dart';

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
    context.read<AnnouncementBloc>().add(LoadAnnouncementsEvent());
    context.read<ProfileBloc>().add(LoadProfileEvent());
    context.read<OfficeBloc>().add(CheckProximityEvent());
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
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state is ProfileLoaded
                        ? "Hello ${state.user.name}"
                        : "Hello",
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
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            child: const _AvatarAction().paddingAll(16),
          ),
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
                const AnnouncementCarousel(),
                const SizedBox(height: 8),
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

/// The user's avatar, from `GET /api/me`. Falls back to an initial: the
/// contract's example avatarUrl is on cdn.example.com and does not resolve.
class _AvatarAction extends StatelessWidget {
  const _AvatarAction();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state is ProfileLoaded ? state.user : null;
        final fallback = CircleAvatar(
          radius: 25,
          backgroundColor: navyDark,
          child: Text(
            user == null || user.name.isEmpty
                ? '?'
                : user.name[0].toUpperCase(),
            style: nbutils.boldTextStyle(size: 18, color: white),
          ),
        );

        if (user?.avatarUrl == null) return fallback;

        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: user!.avatarUrl!,
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            placeholder: (_, __) => fallback,
            errorWidget: (_, __, ___) => fallback,
          ),
        );
      },
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
