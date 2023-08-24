import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otaqu/presentation/pages/dashboard_notification/components/activities.dart';

class DashboardNotificationPage extends StatefulWidget {
  const DashboardNotificationPage({super.key});

  @override
  State<DashboardNotificationPage> createState() =>
      _DashboardNotificationPageState();
}

class _DashboardNotificationPageState extends State<DashboardNotificationPage>
    with SingleTickerProviderStateMixin {
  int tabIndex = 0;

  TabController? _tabController;

  BoxDecoration setBgTab(int currentIndex) {
    if (tabIndex == currentIndex) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color(0xFFF2F2F2),
      );
    } else {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.transparent,
      );
    }
  }

  TextStyle setColorText(int currentIndex) {
    if (tabIndex == currentIndex) {
      return TextStyle(
        color: Colors.green,
        fontWeight: FontWeight.bold,
      );
    } else {
      return TextStyle(
        color: Colors.black38,
        fontWeight: FontWeight.bold,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title, history button
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "My Notifications",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: Activities(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
