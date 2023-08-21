import 'destination.dart';

part 'base_destination.g.dart';

class BaseDestination {
  int? code;
  bool? status;
  String? message;
  List<Destination>? data;

  BaseDestination({this.code, this.status, this.message, this.data});

  factory BaseDestination.fromJson(Map<String, dynamic> json) {
    return _$BaseDestinationFromJson(json);
  }

  Map<String, dynamic> toJson() => _$BaseDestinationToJson(this);
}
