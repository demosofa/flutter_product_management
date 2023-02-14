import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteHelper {
  static const String _tableUser =
      'CREATE TABLE IF NOT EXISTS User (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, address TEXT, note TEXT, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)';

  static const dynamic _tableBrand =
      'CREATE TABLE IF NOT EXISTS Brand (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, address TEXT, note TEXT, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP)';

  static const _tableProduct =
      'CREATE TABLE IF NOT EXISTS Product (id INTEGER PRIMARY KEY, name TEXT, note TEXT, cost INTEGER, price INTEGER, init INTEGER, sold INTEGER DEFAULT 0 NOT NULL, updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, brandId INTEGER NOT NULL, FOREIGN KEY (brandId) REFERENCES Brand (id))';

  static Database? _db;
  static Future<Database> get db async => _db ??= await openDatabase(
        join((await getApplicationDocumentsDirectory()).path, "gas_db"),
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute(_tableUser);
          await db.execute(_tableBrand);
          await db.execute(_tableProduct);
        },
        onOpen: (db) async {
          // final check = await databaseExists(join(await getDatabasesPath(), "gas_db"));
          // log(check.toString());
          // final checkTable = await db.rawQuery(
          //     "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='Brand'");
          // log('check if table exists $checkTable');
          // log('get db path: ${db.path}');
          // await delete();
        },
      );

  static Future<bool> close() async {
    if (_db == null || !_db!.isOpen) return false;
    await _db!.close();
    return true;
  }

  static Future<bool> delete() async {
    if (_db == null || _db!.path.isEmpty) return false;
    await databaseFactory.deleteDatabase(_db!.path);
    return true;
  }

  static Future<bool> drop(String tableName) async {
    if (_db == null || !_db!.isOpen) return false;
    await _db!.execute('DROP TABLE IF EXISTS $tableName');
    return true;
  }
}
