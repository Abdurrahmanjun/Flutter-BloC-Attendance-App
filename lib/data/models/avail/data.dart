import 'package.dart';

part 'data.g.dart';

class Data {
  int? totalPage;
  int? currentPage;
  List<Package>? packages;

  Data({this.totalPage, this.currentPage, this.packages});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
