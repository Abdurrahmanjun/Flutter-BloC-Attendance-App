import 'data.dart';

part 'base_login.g.dart';

class BaseLogin {
  int? code;
  bool? success;
  String? message;
  Data? data;

  BaseLogin({this.code, this.success, this.message, this.data});

  factory BaseLogin.fromJson(Map<String, dynamic> json) {
    return _$BaseLoginFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BaseLoginToJson(this);
}
