import 'package:flutter/material.dart';

var defaultShadow = BoxShadow(
  color: const Color(0xff000000).withOpacity(0.1),
  blurRadius: 10,
  offset: const Offset(0, 0),
);

var textFieldBoxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(5),
    boxShadow: const [
      BoxShadow(color: Colors.blueGrey, blurRadius: 1, offset: Offset(0, 0.1))
    ]);
