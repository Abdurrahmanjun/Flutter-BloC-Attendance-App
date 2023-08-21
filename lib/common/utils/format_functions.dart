class FormatFunctions {
  static String changeFormatPrice(String value) {
    String result = value.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), '.');
    return result;
  }

  static String changeFormatPriceToString(String value) {
    String result = value.replaceAll('.', '');
    return result;
  }
}
