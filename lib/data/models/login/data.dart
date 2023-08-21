part 'data.g.dart';

class Data {
  String? accessToken;
  String? tokenType;
  int? expiresIn;

  Data({this.accessToken, this.tokenType, this.expiresIn});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

  Map<String, dynamic> toJson() => _$DataToJson(this);
}
