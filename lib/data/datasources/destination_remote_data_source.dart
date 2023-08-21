import 'package:dio/dio.dart';
import 'package:otaqu/data/models/destination/destination.dart';
import 'package:otaqu/data/models/destination/base_destination.dart';

abstract class DestinationRemoteDataSource {
  Future<List<Destination>> getDestination({required String token});
}

class DestinationRemoteDataSourceImpl implements DestinationRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  DestinationRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<List<Destination>> getDestination({required String token}) async {
    String url = "$baseUrl:4100/destination";
    Map<String, dynamic> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };

    var response = await dio.getUri(
      Uri.parse(url),
      options: Options(headers: headers),
    );

    var result = BaseDestination.fromJson(response.data);
    return result.data!;
  }
}
