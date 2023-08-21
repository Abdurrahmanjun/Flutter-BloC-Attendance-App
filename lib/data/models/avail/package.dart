import 'destination.dart';

part 'package.g.dart';

class Package {
  int? packageId;
  String? name;
  int? price;
  String? currency;
  int? day;
  String? operationTimeIn;
  String? operationTimeOut;
  String? timeZone;
  List<String>? images;
  int? packageTypeId;
  String? packageTypeName;
  bool? isInstallment;
  List<Destination>? destinations;

  Package({
    this.packageId,
    this.name,
    this.price,
    this.currency,
    this.day,
    this.operationTimeIn,
    this.operationTimeOut,
    this.timeZone,
    this.images,
    this.packageTypeId,
    this.packageTypeName,
    this.isInstallment,
    this.destinations,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return _$PackageFromJson(json);
  }

  Map<String, dynamic> toJson() => _$PackageToJson(this);
}
