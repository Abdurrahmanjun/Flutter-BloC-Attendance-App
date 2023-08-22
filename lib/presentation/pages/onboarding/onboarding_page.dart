import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otaqu/common/utils/constants.dart';
import 'package:otaqu/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'package:otaqu/presentation/pages/auth/login_page.dart';
import 'package:otaqu/presentation/pages/dashboard_home/dashboard_home_page.dart';
import 'package:otaqu/presentation/pages/dashboard_navigation/dashboard_navigation_page.dart';
import 'package:otaqu/presentation/pages/onboarding/components/onboarding_content_component.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.all(30),
        alignment: Alignment.center,
        child: Column(
          children: [
            Flexible(
              child: PageView.builder(
                controller: pageController,
                itemCount: onboardingImagePaths.length,
                onPageChanged: (value) {
                  BlocProvider.of<OnboardingBloc>(context)
                      .add(RunSliderEvent(id: value));
                },
                itemBuilder: (context, index) {
                  return ContentOnBoarding(
                    imageUrl: onboardingImagePaths[index].imageUrl,
                    title: onboardingImagePaths[index].title,
                    subtitle: onboardingImagePaths[index].subtitle,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            BlocBuilder<OnboardingBloc, OnboardingState>(
              builder: (context, state) {
                if (state is LoadedSliderState) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: onboardingImagePaths
                            .asMap()
                            .keys
                            .map((e) => Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: state.id == e
                                        ? const Color(0xffE91E5A)
                                        : const Color(0xffC8C8C8),
                                    shape: BoxShape.circle,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 30),
                      state.id == 0
                          ? Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LoginPage(),
                                        ),
                                      );
                                      BlocProvider.of<OnboardingBloc>(context)
                                          .add(SetOnBoardingEvent());
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffE91E5A),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text("Lewati"),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      pageController.animateToPage(
                                        state.id + 1,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffE91E5A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Selanjutnya",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LoginPage(),
                                        ),
                                      );
                                      BlocProvider.of<OnboardingBloc>(context)
                                          .add(SetOnBoardingEvent());
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffE91E5A),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Ayo Mulai!",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: onboardingImagePaths
                            .asMap()
                            .keys
                            .map((e) => Container(
                                  width: 10,
                                  height: 10,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: e == 0
                                        ? const Color(0xffE91E5A)
                                        : const Color(0xffC8C8C8),
                                    shape: BoxShape.circle,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginPage(),
                                  ),
                                );
                                BlocProvider.of<OnboardingBloc>(context)
                                    .add(SetOnBoardingEvent());
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xffE91E5A),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text("Lewati"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                pageController.animateToPage(
                                  1,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xffE91E5A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "Selanjutnya",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  );
                }
              },
            ),
          ],
        ),
      )),
    );
  }
}
