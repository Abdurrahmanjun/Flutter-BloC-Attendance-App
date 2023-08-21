import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:otaqu/data/models/avail/base_avail.dart';

abstract class AvailRemoteDataSource {
  Future<BaseAvail> getAvail({
    required String token,
    required int typeId,
  });
}

class AvailRemoteDataSourceImpl implements AvailRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AvailRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<BaseAvail> getAvail({
    required String token,
    required int typeId,
  }) async {
    String url = "$baseUrl:4100/avail";
    Map<String, dynamic> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
    Map<String, dynamic> body = {
      "type_source": "location",
      "type_id": typeId,
      "destination_id": 1270,
      "min_price": 0,
      "max_price": 10000000000,
      "page": 1,
      "order_by": "lowest",
      "reference": "search"
    };

    var response = await dio.postUri(
      Uri.parse(url),
      options: Options(headers: headers),
      data: json.encode(body),
    );

    var result = BaseAvail.fromJson(response.data);
    return result;
  }
}
