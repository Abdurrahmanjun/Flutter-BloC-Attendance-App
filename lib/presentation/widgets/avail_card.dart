import 'package:flutter/material.dart';
import 'package:otaqu/common/utils/format_functions.dart';

class AvailCard extends StatelessWidget {
  const AvailCard({
    required this.imageUrl,
    required this.name,
    required this.country,
    required this.price,
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final String name;
  final String country;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Placeholder(fallbackHeight: 70),

            // Image.network(
            //   imageUrl,
            //   errorBuilder: (context, error, stackTrace) {
            //     print(error);
            //     return SizedBox();
            //   },
            // ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name),
                const SizedBox(height: 10),
                Text(country),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "IDR ${FormatFunctions.changeFormatPrice(price)}",
                      style: const TextStyle(
                        color: Color(0xffE91E5A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
