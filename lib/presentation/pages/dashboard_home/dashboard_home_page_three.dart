// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;

import 'package:otaqu/common/utils/colors.dart';
import 'package:otaqu/common/utils/constants.dart';
import 'package:otaqu/presentation/pages/dashboard_home/components/hrm_diagram_card.dart';
import 'package:otaqu/presentation/pages/profile/profile_page.dart';

class DashboardHomePageThree extends StatefulWidget {
  const DashboardHomePageThree({super.key});

  @override
  State<DashboardHomePageThree> createState() => _DashboardHomePageThreeState();
}

class _DashboardHomePageThreeState extends State<DashboardHomePageThree> {
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
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  decoration: BoxDecoration(
                    color: navyDark,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                        topRight: Radius.circular(16.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: grey.withOpacity(0.2),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  const Row(
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '09:00',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: white,
                                            ),
                                          ),
                                          Text(
                                            'Waktu terakhir check-in',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ).paddingBottom(16),
                                  Row(
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          var snackbar = const SnackBar(
                                            content: Text(
                                                'Selamat, data berhasil ditambahkan.'),
                                            backgroundColor: infoGreen,
                                            margin: EdgeInsets.all(8),
                                            behavior: SnackBarBehavior.floating,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackbar);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: koswaraOrange),
                                          child: const Text(
                                            "CHECK OUT",
                                            style: TextStyle(
                                              color: darkText,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ).paddingAll(16),
                                        ).paddingBottom(8),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100.0)),
                                        border: Border.all(
                                            width: 2,
                                            color: Colors.grey.shade300),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.add_a_photo_outlined,
                                              color: Colors.grey.shade300)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).paddingAll(16),
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
                  decoration: const BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Sales Sections
                      const _HrmTextSection(title: "Jumlah Sales")
                          .paddingBottom(16),
                      Container(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 1,
                              spreadRadius: 0.5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const _ItemSalesGroup(
                                  title: "Sales Aktif",
                                  counter: 20,
                                  color: infoGreen,
                                ),
                                8.height,
                                const _ItemSalesGroup(
                                  title: "Sales Non Aktif",
                                  counter: 5,
                                  color: infoRed,
                                ),
                              ],
                            ).paddingOnly(
                                left: 24, right: 24, top: 4, bottom: 16),
                            const Divider(color: Colors.black38),
                            const Text(
                              "+ Tambah Sales Baru",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ).paddingTop(8)
                          ],
                        ),
                      ),
                      32.height,
                      // laporan kehadiran
                      const _HrmTextSection(title: "Laporan Kehadiran")
                          .paddingBottom(16),
                      // laporan kehadiran user
                      Container(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 25, right: 20, left: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 1,
                              spreadRadius: 0.5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Absensi Kamu",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black38,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ).paddingRight(24),
                                ),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100.0)),
                                    border: Border.all(
                                        width: 2, color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      16.height,
                      // laporan kehadiran karyawan
                      Container(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 25, right: 20, left: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black38,
                              blurRadius: 1,
                              spreadRadius: 0.5,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Absensi Karyawan",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.black38,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ).paddingRight(24),
                                ),
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100.0)),
                                    border: Border.all(
                                        width: 2, color: Colors.grey.shade300),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      16.height,
                    ],
                  ).paddingOnly(left: 24, right: 24, top: 32, bottom: 16),
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

class _ItemSalesGroup extends StatelessWidget {
  final String? title;
  final int? counter;
  final Color color;

  const _ItemSalesGroup({
    Key? key,
    this.title,
    this.counter = 0,
    this.color = infoGreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          height: 48,
          width: 3,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 8,
                  bottom: 8,
                ),
                child: Text(
                  '$title',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: Icon(Icons.group_outlined),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      "$counter",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: darkerText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      'Orang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: -0.2,
                        color: grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
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
