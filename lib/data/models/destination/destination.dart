part 'datum.g.dart';

class Destination {
  int? destinationId;
  String? typeSource;
  String? typeName;
  String? name;
  int? packageTypeId;

  Destination({
    this.destinationId,
    this.typeSource,
    this.typeName,
    this.name,
    this.packageTypeId,
  });

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);

  Map<String, dynamic> toJson() => _$DestinationToJson(this);
}
