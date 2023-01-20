import 'package:sqflite/sqflite.dart';

class SQLiteHelper {
  static Database? _db;
  static Future<void> _createUserTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS User (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, address TEXT, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
  }

  static Future<void> _createBrandTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Brand (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, address TEXT, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
  }

  static Future<void> _createProductTable(Database db) async {
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Product (id INTEGER PRIMARY KEY, name TEXT, cost INTEGER, price INTEGER, init INTEGER, sold INTEGER DEFAULT 0 NOT NULL, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, brandId INTEGER NOT NULL, FOREIGN KEY (brandId) REFERENCES Brand (id))');
  }

  static Future<Database?> open({int version = 1}) async {
    if (_db == null || _db!.isOpen) {
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

  static Future<void> drop(String tableName) async {
    if (_db != null || _db!.isOpen) {
      await _db!.execute('DROP TABLE IF EXISTS $tableName');
    }
  }
}
