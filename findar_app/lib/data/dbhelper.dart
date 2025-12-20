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
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
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
        owner_name TEXT,
        owner_image TEXT,
        owner_phone TEXT
      );

    ''');
    await db.execute('''
INSERT INTO $table (title, description, price, location, bedrooms, bathrooms, classification, property_type, image, is_online, created_at, updated_at, is_boosted, boost_expiry_date, sponsorship_plan_id, owner_name, owner_image, owner_phone) VALUES
      ('Cozy Cottage', 'A lovely cottage in the countryside.', 150000, 'Countryside', 2, 1, 'Residential', 'Cottage', 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, NULL, NULL, 'John Doe', 'https://i.pravatar.cc/150?img=1', '123-456-7890'),
      ('Modern Apartment', 'A modern apartment in the city center.', 250000, 'City Center', 3, 2, 'Residential', 'Apartment', 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'Jane Smith', 'https://i.pravatar.cc/150?img=2', '098-765-4321'),
      ('Beach House', 'A beautiful house by the beach.', 500000, 'Beachfront', 4, 3, 'Residential', 'House', 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'Alice Johnson', 'https://i.pravatar.cc/150?img=3', '555-555-5555'),
      ('Luxury Villa', 'A luxurious villa with a pool.', 1000000, 'Luxury Area', 5, 4, 'Residential', 'Villa', 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, NULL, NULL, 'Bob Brown', 'https://i.pravatar.cc/150?img=4', '444-444-4444'),
      ('Urban Loft', 'An urban loft with modern amenities.', 300000, 'Downtown', 2, 1, 'Residential', 'Loft', 'https://images.unsplash.com/photo-1502672260066-6bc2614e44a4?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'Charlie Davis', 'https://i.pravatar.cc/150?img=5', '333-333-3333'),
      ('Suburban Home', 'A spacious home in the suburbs.', 400000, 'Suburb', 4, 2, 'Residential', 'House', 'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'Diana Evans', 'https://i.pravatar.cc/150?img=6', '222-222-2222'),
      ('Penthouse Suite', 'A stunning penthouse with a view.', 750000, 'Skyline', 3, 2, 'Residential', 'Penthouse', 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'Ethan Foster', 'https://i.pravatar.cc/150?img=7', '111-111-1111'),
      ('Country Farm', 'A farm with vast land.', 600000, 'Countryside', 5, 3, 'Residential', 'Farm', 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'Fiona Green', 'https://i.pravatar.cc/150?img=8', '666-666-6666'),
      ('Charming Bungalow', 'A charming bungalow with a garden.', 200000, 'Suburb', 2, 1, 'Residential', 'Bungalow', 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'George Harris', 'https://i.pravatar.cc/150?img=9', '777-777-7777'),
      ('Stylish Studio', 'A stylish studio apartment.', 180000, 'City Center', 1, 1, 'Residential', 'Studio', 'https://images.unsplash.com/photo-1502672023488-70e25813eb80?w=800', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 0, NULL, NULL, 'Hannah Ivers', 'https://i.pravatar.cc/150?img=10', '888-888-8888');
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
