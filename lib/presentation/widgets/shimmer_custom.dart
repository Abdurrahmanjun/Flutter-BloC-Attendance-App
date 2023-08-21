import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCustom extends StatelessWidget {
  const ShimmerCustom({this.child, super.key});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFDBE2EC),
      highlightColor: const Color(0xFFF4F6F9),
      child: Container(
        color: Colors.black,
        child: child,
      ),
    );
  }
}
