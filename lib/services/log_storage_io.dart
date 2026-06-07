import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/log_access.dart';

class LogStorage {
  static const String _dbName = 'nfc_logs.db';
  static const int _dbVersion = 1;
  static const String _tableName = 'access_logs';

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        badgeId TEXT NOT NULL,
        nom TEXT NOT NULL,
        statut TEXT NOT NULL,
        dateScan TEXT NOT NULL
      )
    ''');
  }

  Future<List<LogAccess>> loadLogs() async {
    final db = await _db;
    final maps = await db.query(
      _tableName,
      orderBy: 'dateScan DESC',
    );
    return maps.map((row) => LogAccess.fromJson(row)).toList();
  }

  Future<void> addLog(LogAccess log) async {
    final db = await _db;
    await db.insert(_tableName, log.toJson());
  }

  Future<void> clearLogs() async {
    final db = await _db;
    await db.delete(_tableName);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
