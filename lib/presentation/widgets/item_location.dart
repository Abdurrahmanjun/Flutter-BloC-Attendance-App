import 'package:flutter/material.dart';

class ItemLocation extends StatelessWidget {
  const ItemLocation({required this.value, required this.onTap, super.key});

  final String value;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Color(0xff202020),
          ),
        ),
      ),
    );
  }
}
