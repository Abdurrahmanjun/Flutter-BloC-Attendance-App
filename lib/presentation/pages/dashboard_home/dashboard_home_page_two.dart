import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart' as nbutils;
import 'package:otaqu/common/utils/colors.dart';
import 'package:otaqu/common/utils/constants.dart';
import 'package:otaqu/presentation/pages/dashboard_home/components/hrm_diagram_card.dart';
import 'package:otaqu/presentation/pages/profile/profile_page.dart';

class DashboardHomePageTwo extends StatefulWidget {
  const DashboardHomePageTwo({super.key});

  @override
  State<DashboardHomePageTwo> createState() => _DashboardHomePageTwoState();
}

class _DashboardHomePageTwoState extends State<DashboardHomePageTwo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: nbutils.appBarWidget(
        "Hello Abdurrahmanjun",
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello Abdurrahmanjun",
              style: nbutils.boldTextStyle(size: 18, color: darkText),
            ),
            Text(
              "Have a nice day!",
              style: nbutils.secondaryTextStyle(color: bodyColor, size: 12),
            )
          ],
        ).paddingTop(12),
        showBack: false,
        elevation: 0,
        actions: [
          Container(
            height: 50.0,
            width: 50.0,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "https://images.pexels.com/photos/5110839/pexels-photo-5110839.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
          ).paddingOnly(left: 16, right: 16, top: 8),
        ],
        color: context.scaffoldBackgroundColor,
      ),
      backgroundColor: Colors.transparent,
      body: ListView(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(68.0)),
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 4),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      height: 48,
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: HexColor('#87A0E5')
                                            .withOpacity(0.5),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4, bottom: 2),
                                            child: Text(
                                              'Monthly Presence',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                letterSpacing: -0.1,
                                                color: grey.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              const SizedBox(
                                                width: 28,
                                                height: 28,
                                                child:
                                                    Icon(Icons.pending_actions),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4, bottom: 3),
                                                child: Text(
                                                  '17',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color: darkerText,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4, bottom: 3),
                                                child: Text(
                                                  'Times',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    letterSpacing: -0.2,
                                                    color:
                                                        grey.withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      height: 48,
                                      width: 2,
                                      decoration: BoxDecoration(
                                        color: HexColor('#F56E98')
                                            .withOpacity(0.5),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4, bottom: 2),
                                            child: Text(
                                              'Yearly Leave',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                letterSpacing: -0.1,
                                                color: grey.withOpacity(0.5),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: <Widget>[
                                              const SizedBox(
                                                width: 28,
                                                height: 28,
                                                child:
                                                    Icon(Icons.pending_actions),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4, bottom: 3),
                                                child: Text(
                                                  '8',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color: darkerText,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8, bottom: 3),
                                                child: Text(
                                                  'Times',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    letterSpacing: -0.2,
                                                    color:
                                                        grey.withOpacity(0.5),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(100.0)),
                                      border: Border.all(
                                          width: 4,
                                          color:
                                              nearlyDarkBlue.withOpacity(0.2)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          '47',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 24,
                                            letterSpacing: 0.0,
                                            color: nearlyDarkBlue,
                                          ),
                                        ),
                                        Text(
                                          'Times',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            letterSpacing: 0.0,
                                            color: grey.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: CustomPaint(
                                    painter: CurvePainter(colors: [
                                      nearlyDarkBlue,
                                      HexColor("#8A98E8"),
                                      HexColor("#8A98E8")
                                    ], angle: 140 + (360 - 140)),
                                    child: SizedBox(
                                      width: 108,
                                      height: 108,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              height: 110.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  SizedBox(
                    width: 10.0,
                  ),
                  card4(
                    colorTop: Color(0xFFF07DA4),
                    colorBottom: Color(0xFFF5AE87),
                    title: "Overtime",
                  ),
                  card4(
                      colorTop: Color(0xFF63CCD1),
                      colorBottom: Color(0xFF75E3AC),
                      title: "Sick Leave"),
                  card4(
                      colorTop: Color(0xFF9183FC),
                      colorBottom: Color(0xFFDB8EF6),
                      title: "Reimburs..."),
                  card4(
                      colorTop: Color(0xFF56B4EE),
                      colorBottom: Color(0xFF59CCE1),
                      title: "late atten..."),
                  InkWell(
                    onTap: () {},
                    child: card4(
                        colorTop: Color(0xFF74EBD5),
                        colorBottom: Color(0xFFACB6E5),
                        title: "Employee Data"),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Your Last Absences",
                    textAlign: TextAlign.left,
                    style: nbutils.boldTextStyle(size: 18, color: darkText),
                  ),
                ),
                InkWell(
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "others",
                          textAlign: TextAlign.left,
                          style: nbutils.boldTextStyle(
                              size: 18, color: nearlyDarkBlue),
                        ),
                        const SizedBox(
                          height: 38,
                          width: 26,
                          child: Icon(
                            Icons.arrow_forward,
                            color: darkText,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          _cardFood1(context),
          _cardFood1(context),
          _cardFood1(context)
        ],
      ),
    );
  }
}

class card4 extends StatelessWidget {
  Color? colorTop, colorBottom;
  String? image, title;
  card4({this.colorTop, this.colorBottom, this.title, this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 4.0),
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 80.0,
              width: 80.0,
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: 8.0, color: Colors.black12)],
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                gradient: LinearGradient(
                    colors: [colorTop!, colorBottom!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(
                title!,
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: "Sofia",
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _cardFood1(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0, left: 16.0, right: 16),
    child: Container(
      decoration: BoxDecoration(
        color: white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: grey.withOpacity(0.2),
            blurRadius: 1.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Color(0xFF1E2026),
            child: Container(
              height: 85.0,
              width: 85.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      "https://images.pexels.com/photos/699459/pexels-photo-699459.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Text(
                    "Checking in the office",
                    style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Sofia",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.pending_actions,
                          size: 18.0,
                          color: Colors.black26,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "2023-08-16 17:08:21",
                          style: TextStyle(
                              color: Colors.black45,
                              fontFamily: "Sofia",
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.0,
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
