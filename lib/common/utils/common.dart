import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otaqu/common/utils/colors.dart';
import 'package:html/parser.dart';

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(
        id: 1,
        name: 'English',
        subTitle: 'English',
        languageCode: 'en',
        fullLanguageCode: 'en_en-US',
        flag: 'images/flag/ic_us.png'),
    LanguageDataModel(
        id: 2,
        name: 'Indonesia',
        subTitle: 'Indonesia',
        languageCode: 'id',
        fullLanguageCode: 'id-ID',
        flag: 'images/flag/ic_indonesia.png'),
  ];
}

InputDecoration inputDecoration(BuildContext context,
    {String? hint,
    String? label,
    TextStyle? textStyle,
    Widget? prefix,
    EdgeInsetsGeometry? contentPadding,
    Widget? prefixIcon}) {
  return InputDecoration(
    contentPadding: contentPadding,
    labelText: label,
    hintText: hint,
    hintStyle: textStyle ?? secondaryTextStyle(),
    labelStyle: textStyle ?? secondaryTextStyle(),
    prefix: prefix,
    prefixIcon: prefixIcon,
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.red, width: 1.0)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.red, width: 1.0)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(width: 1.0, color: context.dividerColor)),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(width: 1.0, color: context.dividerColor)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: primaryColor, width: 1.0)),
    alignLabelWithHint: true,
  );
}

Future<File> getImageSource({bool isCamera = true}) async {
  final picker = ImagePicker();
  final pickedImage = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery);
  return File(pickedImage!.path);
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

Future<List<File>> getMultipleFile() async {
  FilePickerResult? filePickerResult;
  List<File> imgList = [];
  filePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg']);

  if (filePickerResult != null) {
    imgList = filePickerResult.paths.map((path) => File(path!)).toList();
  }
  return imgList;
}

int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}
