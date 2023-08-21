import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otaqu/common/utils/style_widget.dart';
import 'package:otaqu/presentation/bloc/avail/avail_bloc.dart';
import 'package:otaqu/presentation/widgets/avail_card.dart';
import 'package:otaqu/presentation/widgets/shimmer_custom.dart';

class DetailHomePage extends StatelessWidget {
  const DetailHomePage({required this.destination, super.key});

  final String destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destination),
        backgroundColor: const Color(0xffE91E5A),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(
            top: 30,
            left: 30,
            right: 30,
          ),
          child: BlocBuilder<AvailBloc, AvailState>(
            builder: (context, state) {
              if (state is LoadedGetAvailState) {
                if (state.result.data!.packages != null) {
                  final avails = state.result.data!.packages!;

                  return ListView.builder(
                    itemCount: avails.length,
                    itemBuilder: (context, index) {
                      final item = avails[index];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [defaultShadow],
                        ),
                        margin: const EdgeInsets.only(
                          bottom: 30,
                        ),
                        child: AvailCard(
                          imageUrl: item.images![0],
                          name: item.name!,
                          country: item.destinations![0].name!,
                          price: item.price.toString(),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text('Uppss saat ini tidak tersedia'),
                  );
                }
              } else {
                return ListView.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [defaultShadow],
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 30,
                      ),
                      child: const ShimmerCustom(
                        child: AvailCard(
                          imageUrl: "",
                          name: "",
                          country: "",
                          price: "",
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
