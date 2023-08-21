part 'destination.g.dart';

class Destination {
  int? destinationId;
  String? name;

  Destination({this.destinationId, this.name});

  factory Destination.fromJson(Map<String, dynamic> json) {
    return _$DestinationFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DestinationToJson(this);
}
