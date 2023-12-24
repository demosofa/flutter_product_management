import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:product_manager/enums/table_name.dart';
import 'package:sqflite/sqflite.dart';

final class SQLiteHelper {
  static final String _tableUser =
      '''CREATE TABLE IF NOT EXISTS ${TableName.user.name} (
    id INTEGER PRIMARY KEY, 
    name TEXT NOT NULL, 
    phone TEXT NOT NULL, 
    address TEXT NOT NULL, 
    note TEXT, 
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP, 
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
  )''';

  static final dynamic _tableBrand =
      '''CREATE TABLE IF NOT EXISTS ${TableName.brand.name} (
    id INTEGER PRIMARY KEY, 
    name TEXT NOT NULL, 
    phone TEXT NOT NULL, 
    address TEXT NOT NULL, 
    note TEXT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP, 
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
  )''';

  static final _tableProduct =
      '''CREATE TABLE IF NOT EXISTS ${TableName.product.name} (
    id INTEGER PRIMARY KEY, 
    name TEXT NOT NULL, 
    note TEXT, 
    price INTEGER NOT NULL, 
    cost INTEGER NOT NULL, 
    init INTEGER NOT NULL, 
    sold INTEGER DEFAULT 0 NOT NULL, 
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP, 
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP, 
    brandId INTEGER NOT NULL, 
    FOREIGN KEY (brandId) REFERENCES ${TableName.brand.name} (id)
  )''';

  static final String _tableFile =
      '''CREATE TABLE IF NOT EXISTS ${TableName.anyFile.name} (
    id INTEGER PRIMARY KEY,
    path TEXT NOT NULL, 
    type TEXT NOT NULL, 
    size INTEGER NOT NULL,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP, 
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    userId INTEGER UNIQUE,
    brandId INTEGER UNIQUE,
    productId INTEGER,
    FOREIGN KEY (userId) REFERENCES ${TableName.user.name} (id),
    FOREIGN KEY (brandId) REFERENCES ${TableName.brand.name} (id),
    FOREIGN KEY (productId) REFERENCES ${TableName.product.name} (id)
  )''';

  static String _triggerTimestamp(String table) => '''
    CREATE TRIGGER IF NOT EXISTS update_timestamp_${table.toLowerCase()}
    AFTER UPDATE ON $table
    BEGIN
      UPDATE $table SET updatedAt = datetime('now') WHERE id = NEW.id;
    END
  ''';

  static Future<void> _createTable(Database db) async {
    await db.execute(_tableUser);
    await db.execute(_tableBrand);
    await db.execute(_tableProduct);
    await db.execute(_tableFile);
  }

  static Future<void> _createTrigger(Database db) async {
    await db.execute(_triggerTimestamp(TableName.user.name));
    await db.execute(_triggerTimestamp(TableName.brand.name));
    await db.execute(_triggerTimestamp(TableName.product.name));
    await db.execute(_triggerTimestamp(TableName.anyFile.name));
  }

  static Database? _db;

  static Future<Database> get db async => _db ??= await openDatabase(
        join((await getApplicationDocumentsDirectory()).path, "gas_db"),
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await _createTable(db);
          await _createTrigger(db);
        },
        onOpen: (db) async {
          // final check = await databaseExists(join(await getDatabasesPath(), "gas_db"));
          // log(check.toString());
          // final checkTable = await db.rawQuery(
          //     "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='Brand'");
          // log('check if table exists $checkTable');
          // log('get db path: ${db.path}');
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
