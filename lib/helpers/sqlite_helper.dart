import 'package:sqflite/sqflite.dart';

class SQLiteHelper {
  static Database? _db;
  static Future<void> _createUserTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXIST User (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, updatedAt TEXT');
  }

  static Future<void> _createBrandTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Brand (id INTEGER PRIMARY KEY, name TEXT, phone Text, updatedAt TEXT)');
  }

  static Future<void> _createProductTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Product (id INTEGER PRIMARY KEY, name TEXT, price INTEGER, brandId INTEGER NOT NULL FOREIGN KEY (brandId) REFERENCES Brand (id), updatedAt TEXT)');
  }

  static Future<Database?> open({int version = 1}) async {
    if (_db != null || !_db!.isOpen) {
      final dbPath = await getDatabasesPath();
      _db = await openDatabase(
        "$dbPath/gas_db",
        version: version,
        onCreate: (db, version) async {
          await _createUserTable(db);
          await _createBrandTable(db);
          await _createProductTable(db);
        },
      );
    }
    return _db;
  }

  static Future<void> close() async {
    if (_db != null || _db!.isOpen) {
      await _db!.close();
    }
  }
}
