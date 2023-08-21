import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otaqu/common/utils/style_widget.dart';
import 'package:otaqu/presentation/bloc/avail/avail_bloc.dart';
import 'package:otaqu/presentation/bloc/destination/destination_bloc.dart';
import 'package:otaqu/presentation/bloc/last_destination/last_destination_bloc.dart';
import 'package:otaqu/presentation/pages/home_details/detail_home_page.dart';
import 'package:otaqu/presentation/widgets/form_search.dart';
import 'package:otaqu/presentation/widgets/item_location.dart';

class CardSearch extends StatelessWidget {
  const CardSearch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [
            Color(0xffE91E5A),
            Color(0xffBE0038),
          ],
        ),
        boxShadow: [defaultShadow],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(48),
                      right: Radius.circular(48),
                    ),
                    color: Color(0xff251E42),
                  ),
                  child: const Text(
                    "Mau liburan kemana? ✈️",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xffFEFEFE),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                BlocBuilder<DestinationBloc, DestinationState>(
                  builder: (context, state) {
                    if (state is LoadedGetDestinationState) {
                      return FormSearch(
                        onChanged: (value) {
                          BlocProvider.of<DestinationBloc>(context).add(
                            SearchEvent(
                              key: value,
                              data: state.result,
                              token: state.token,
                            ),
                          );
                        },
                      );
                    }

                    if (state is LoadedSearchState) {
                      return FormSearch(
                        onChanged: (value) {
                          BlocProvider.of<DestinationBloc>(context).add(
                            SearchEvent(
                              key: value,
                              data: state.oldData,
                              token: state.token,
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
                BlocBuilder<DestinationBloc, DestinationState>(
                  builder: (context, state) {
                    if (state is LoadedSearchState) {
                      final destinations = state.result;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        color: Colors.white,
                        height: destinations.isEmpty
                            ? 0
                            : MediaQuery.of(context).size.height / 5,
                        child: ListView.builder(
                          itemCount: destinations.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final destination = destinations[index];

                            return Column(
                              children: [
                                ItemLocation(
                                  value: destination.name!,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailHomePage(
                                          destination: destination.name!,
                                        ),
                                      ),
                                    );

                                    BlocProvider.of<AvailBloc>(context).add(
                                      GetAvailEvent(
                                        token: state.token,
                                        typeId: destination.destinationId!,
                                      ),
                                    );

                                    BlocProvider.of<LastDestinationBloc>(
                                            context)
                                        .add(
                                      SetLastDestinationEvent(
                                        destination: destination,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
