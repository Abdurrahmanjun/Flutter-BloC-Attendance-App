import 'package:flutter/material.dart';

class ContentOnBoarding extends StatelessWidget {
  const ContentOnBoarding({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Image.asset('assets/images/thumbnail.png'),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: MediaQuery.of(context).size.width / 1.5,
          child: Image.asset(imageUrl),
        ),
        const SizedBox(height: 30),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xff202020),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: Color(
              0xff676768,
            ),
          ),
        ),
      ],
    );
  }
}
