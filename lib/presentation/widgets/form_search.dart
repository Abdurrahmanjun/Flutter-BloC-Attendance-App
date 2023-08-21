import 'package:flutter/material.dart';

class FormSearch extends StatelessWidget {
  const FormSearch({required this.onChanged, Key? key}) : super(key: key);

  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          width: 1,
          // color: appThemes.primary,
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          // labelStyle: TextStyleConstant.mediumRegular
          //     .copyWith(color: appThemes.primary),
          hintText: "Tujuan wisata kamu",
          // hintStyle: TextStyleConstant.mediumRegular.copyWith(
          //   color: appThemes.secondaryVariant,
          // ),
          hintStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            color: Color(0xff676768),
          ),

          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xffE6E6E6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Color(0xffE6E6E6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
        ),
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          color: Color(0xff676768),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
