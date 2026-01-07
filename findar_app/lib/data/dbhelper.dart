import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = "listings.db";
  static const _dbVersion = 1;
  static const table = "property_listings";

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        location TEXT NOT NULL,
        bedrooms INTEGER NOT NULL,
        bathrooms INTEGER NOT NULL,
        classification TEXT NOT NULL,
        property_type TEXT NOT NULL,
        image TEXT NOT NULL,
        is_online INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        is_boosted INTEGER NOT NULL,
        boost_expiry_date INTEGER,
        sponsorship_plan_id TEXT,
        ownerName TEXT,
        ownerImage TEXT,
        ownerPhone TEXT
      );

    ''');
  }

  // CRUD operations ----------------------------------------------------

  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert(table, row);
  }

  Future<int> update(String table, Map<String, dynamic> row) async {
    final db = await database;
    return await db.update(table, row, where: "id = ?", whereArgs: [row["id"]]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: "id = ?", whereArgs: [id]);
  }

  Future<int> clearCachedListings() async {
    final db = await database;
    return await db.delete(table);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql,
    List<Object?> args,
  ) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }
}
