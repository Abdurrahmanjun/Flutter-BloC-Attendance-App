import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otaqu/common/utils/constants.dart';
import 'package:otaqu/presentation/bloc/last_destination/last_destination_bloc.dart';
import 'package:otaqu/presentation/bloc/promo/promo_bloc.dart';
import 'package:otaqu/presentation/widgets/card_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "Home",
        color: context.scaffoldBackgroundColor,
        elevation: 0,
        showBack: false,
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 40,
            horizontal: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Halo Selamat datang ",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                flex: 1,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: promoImagePaths.length,
                  onPageChanged: (value) {
                    BlocProvider.of<PromoBloc>(context)
                        .add(RunSliderEvent(id: value));
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(promoImagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              BlocConsumer<PromoBloc, PromoState>(
                listener: (context, state) {
                  // Future.delayed(Duration(seconds: 5), () {
                  //   if (state is LoadedSliderState) {
                  //     print(state.id);
                  //     _pageController.animateToPage(
                  //       state.id,
                  //       duration: const Duration(milliseconds: 500),
                  //       curve: Curves.easeInOut,
                  //     );

                  //     BlocProvider.of<DestinationBloc>(context)
                  //         .add(RunSliderEvent(id: state.id + 1));
                  //   }
                  // });
                },
                builder: (context, state) {
                  if (state is LoadedSliderState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: promoImagePaths
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
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: promoImagePaths
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
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
              const Flexible(flex: 4, child: CardSearch()),
              const SizedBox(height: 30),
              Flexible(
                flex: 1,
                child: BlocConsumer<LastDestinationBloc, LastDestinationState>(
                  listener: (context, state) {
                    if (state is LoadedSetLastDestinationState) {
                      BlocProvider.of<LastDestinationBloc>(context)
                          .add(GetLastDestinationEvent());
                    }
                  },
                  builder: (context, state) {
                    if (state is LoadedGetLastDestinationState) {
                      final destinations = state.result;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pencarian Terakhir",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: PageView.builder(
                              itemCount: state.result.length,
                              itemBuilder: (context, index) {
                                final destination = destinations[index];
                                return Row(
                                  children: [
                                    Placeholder(
                                        fallbackWidth:
                                            MediaQuery.of(context).size.width /
                                                3),
                                    Expanded(
                                      child: Container(
                                        height: double.infinity,
                                        alignment: Alignment.center,
                                        color: const Color(0xffE91E5A),
                                        child: Text(
                                          destination.name!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20,
                                            color: Color(0xffFEFEFE),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
