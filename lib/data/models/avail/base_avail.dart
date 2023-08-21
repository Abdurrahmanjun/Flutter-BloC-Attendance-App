import 'data.dart';

part 'base_avail.g.dart';

class BaseAvail {
  int? code;
  bool? status;
  String? message;
  Data? data;

  BaseAvail({this.code, this.status, this.message, this.data});

  factory BaseAvail.fromJson(Map<String, dynamic> json) {
    return _$BaseAvailFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BaseAvailToJson(this);
}
