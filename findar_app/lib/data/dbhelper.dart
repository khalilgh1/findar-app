import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = "listings.db";
  // v3: cache rows keep server ids/owners; earlier caches are corrupt and are
  // dropped on upgrade (it's only a cache, the server is the source of truth).
  static const _dbVersion = 3;
  static const table = "property_listings";
  static const usersTable = "users";

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
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create property_listings table aligned with remote api_post schema
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        address TEXT,
        bedrooms INTEGER,
        bathrooms INTEGER,
        livingrooms INTEGER,
        area REAL,
        listing_type TEXT,
        building_type TEXT,
        main_pic TEXT,
        pics TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        boosted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        latitude REAL,
        longitude REAL,
        owner_id INTEGER,
        FOREIGN KEY (owner_id) REFERENCES $usersTable(id)
      )
    ''');

    // Create users table aligned with remote api_customuser schema
    await db.execute('''
      CREATE TABLE $usersTable (
        id INTEGER PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        profile_pic TEXT,
        account_type TEXT NOT NULL DEFAULT 'normal',
        credits INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Drop old table and create new schema
      await db.execute('DROP TABLE IF EXISTS $table');
      await db.execute('DROP TABLE IF EXISTS $usersTable');
      await _onCreate(db, newVersion);
    }
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

  /// Inserts or replaces listing rows (keyed by server id) and their owners
  /// in one transaction.
  Future<void> upsertListings(
    List<Map<String, dynamic>> rows,
    List<Map<String, dynamic>> owners,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final owner in owners) {
        batch.insert(usersTable, owner,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      for (final row in rows) {
        batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> deleteWhere(String table, String where, List<Object?> args) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: args);
  }

  /// Wipes all cached data (used on logout so the next account starts clean).
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(table);
    await db.delete(usersTable);
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

  // User operations ----------------------------------------------------

  Future<int> insertOrUpdateUser(Map<String, dynamic> user) async {
    final db = await database;
    // Use INSERT OR REPLACE to handle both insert and update
    return await db.insert(
      usersTable,
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final results = await db.query(
      usersTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(usersTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearUsers() async {
    final db = await database;
    return await db.delete(usersTable);
  }
}
