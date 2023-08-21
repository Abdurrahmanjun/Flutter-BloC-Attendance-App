import 'dart:async';

import 'package:otaqu/data/models/destination/destination.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._instance() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._instance();

  static Database? _database;

  Future<Database?> get database async {
    _database ??= await _initDb();
    return _database;
  }

  static const String _destination = 'destination';
  static const String _lasDestination = 'lastDestination';

  Future<Database> _initDb() async {
    final path = await getDatabasesPath();
    final databasePath = '$path/otaqu.db';

    var db = await openDatabase(
      databasePath,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE  $_destination (
        destination_id INTEGER PRIMARY KEY,
        type_source TEXT,
        type_name TEXT,
        name TEXT,
        package_type_id INTEGER NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE  $_lasDestination (
        destination_id INTEGER,
        type_source TEXT,
        type_name TEXT,
        name TEXT,
        package_type_id INTEGER NULL
      );
    ''');
  }

  Future<int> insertDestination(Destination value) async {
    final db = await database;
    return await db!.insert(_destination, value.toJson());
  }

  Future<List<Map<String, dynamic>>> getDestination() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(_destination);

    return results;
  }

  Future<int> insertLastDestination(Destination value) async {
    final db = await database;
    return await db!.insert(_lasDestination, value.toJson());
  }

  Future<int> deleteLastDestination(Destination value) async {
    final db = await database;
    return await db!.delete(_lasDestination,
        where: 'destination_id = ${value.destinationId}');
  }

  Future<List<Map<String, dynamic>>> getLastDestination() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(_lasDestination);

    return results;
  }
}
