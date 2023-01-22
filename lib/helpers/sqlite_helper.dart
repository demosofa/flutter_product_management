import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteHelper {
  static Database? _db;
  static const String tableUser =
      'CREATE TABLE IF NOT EXISTS User (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, address TEXT, note TEXT, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)';

  static const tableBrand =
      'CREATE TABLE IF NOT EXISTS Brand (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, address TEXT, note TEXT, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)';

  static const tableProduct =
      'CREATE TABLE IF NOT EXISTS Product (id INTEGER PRIMARY KEY, name TEXT, note TEXT, cost INTEGER, price INTEGER, init INTEGER, sold INTEGER DEFAULT 0 NOT NULL, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, brandId INTEGER NOT NULL, FOREIGN KEY (brandId) REFERENCES Brand (id))';

  static Future<Database?> open({int version = 1}) async {
    if (_db == null || _db!.isOpen) {
      final String dbPath = join(await getDatabasesPath(), "gas_db");
      _db = await openDatabase(
        dbPath,
        version: version,
        onCreate: (db, version) async {
          await db.execute(tableUser);
          await db.execute(tableBrand);
          await db.execute(tableProduct);
        },
      );
      final check = await _db!.rawQuery(
          "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='Brand'");
      log('check if table exists $check');
    }
    return _db;
  }

  static Future<bool> close() async {
    if (_db == null || !_db!.isOpen) return false;
    await _db!.close();
    return true;
  }

  static Future<bool> delete() async {
    if (_db == null || _db!.path.isEmpty) return false;
    await deleteDatabase(_db!.path);
    return true;
  }

  static Future<bool> drop(String tableName) async {
    if (_db == null || !_db!.isOpen) return false;
    await _db!.execute('DROP TABLE IF EXISTS $tableName');
    return true;
  }
}
