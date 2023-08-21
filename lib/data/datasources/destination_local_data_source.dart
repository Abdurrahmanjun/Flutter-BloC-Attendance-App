import 'package:dartz/dartz.dart';
import 'package:otaqu/data/models/destination/destination.dart';

import 'db/database_helper.dart';

abstract class DestinationLocalDataSource {
  Future<Unit> insertDestination(Destination destination);
  Future<List<Destination>> getListDestination();
  Future<Unit> insertLastDestination(Destination destination);
  Future<Unit> deleteLastDestination(Destination destination);
  Future<List<Destination>> getLastListDestination();
}

class DestinationLocalDataSourceImpl implements DestinationLocalDataSource {
  final DatabaseHelper databaseHelper;

  DestinationLocalDataSourceImpl({
    required this.databaseHelper,
  });

  @override
  Future<Unit> insertDestination(Destination destination) async {
    await databaseHelper.insertDestination(destination);
    return Future.value(unit);
  }

  @override
  Future<List<Destination>> getListDestination() async {
    final result = await databaseHelper.getDestination();
    return result.map((data) => Destination.fromJson(data)).toList();
  }

  @override
  Future<List<Destination>> getLastListDestination() async {
    final result = await databaseHelper.getLastDestination();
    return result.map((data) => Destination.fromJson(data)).toList();
  }

  @override
  Future<Unit> insertLastDestination(Destination destination) async {
    await databaseHelper.insertLastDestination(destination);
    return Future.value(unit);
  }

  @override
  Future<Unit> deleteLastDestination(Destination destination) async {
    await databaseHelper.deleteLastDestination(destination);
    return Future.value(unit);
  }
}
