import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

enum SearchCriteria {
  substanceName,
  maxSingleDose,
  avgDailyDose,
  casNumber,
  hazardClass,
}

enum SortType {
  substanceNameAscending,
  substanceNameDescending,
  hazardClassAscending,
  hazardClassDescending,
}

class DatabaseService {
  late Database _database;

  Future<Database> get database async {
    _database = await _initializeDatabase();
    return _database;
  }

  Future<Database> _initializeDatabase() async {
    String databasesPath = await getDatabasesPath();
    String databasePath = join(databasesPath, 'database.db');

    await _copyDatabase(databasePath);

    Database database = await openDatabase(databasePath);

    return database;
  }


  // Копіювання бази даних 
  Future<void> _copyDatabase(String databasePath) async {
    ByteData data = await rootBundle.load('assets/database.db');
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(databasePath).writeAsBytes(bytes);
  }

  Future<List<Map<String, dynamic>>> searchAndSortConcentrations(String query, SearchCriteria criteria, SortType sortType) async {
    Database db = await database;
    String columnName = _getColumnName(criteria);
    String orderBy = _getOrderByClause(sortType);

    return await db.rawQuery('''
      SELECT * FROM AtmosphericConcentrations
      WHERE $columnName LIKE ?
      ORDER BY $orderBy
    ''', ['%$query%']);
  }

  //Вибір критрію пошуку
  String _getColumnName(SearchCriteria criteria) {
    switch (criteria) {
      case SearchCriteria.substanceName:
        return 'substance_name';
      case SearchCriteria.maxSingleDose:
        return 'max_single_dose_limit';
      case SearchCriteria.avgDailyDose:
        return 'avg_daily_limit';
      case SearchCriteria.casNumber:
        return 'cas_number';
      case SearchCriteria.hazardClass:
        return 'hazard_class';
      default:
        throw Exception('Invalid SearchCriteria');
    }
  }

  //Вибір критерію сортування
  String _getOrderByClause(SortType sortType) {
    switch (sortType) {
      case SortType.substanceNameAscending:
        return 'substance_name ASC';
      case SortType.substanceNameDescending:
        return 'substance_name DESC';
      case SortType.hazardClassAscending:
        return 'CAST(hazard_class AS INTEGER) ASC';
      case SortType.hazardClassDescending:
        return 'CAST(hazard_class AS INTEGER) DESC';
      default:
        throw Exception('Invalid SortType');
    }
  }
}
