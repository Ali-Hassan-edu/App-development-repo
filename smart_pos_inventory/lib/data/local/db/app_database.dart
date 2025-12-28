import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'smart_pos_inventory.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Products
        await db.execute('''
        CREATE TABLE products(
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          sku TEXT,
          category TEXT,
          price REAL NOT NULL,
          cost REAL,
          stock INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL,
          updatedAt INTEGER NOT NULL
        )
        ''');

        // Inventory logs
        await db.execute('''
        CREATE TABLE inventory_logs(
          id TEXT PRIMARY KEY,
          productId TEXT NOT NULL,
          type TEXT NOT NULL,
          qty INTEGER NOT NULL,
          note TEXT,
          createdAt INTEGER NOT NULL
        )
        ''');

        // Sales
        await db.execute('''
        CREATE TABLE sales(
          id TEXT PRIMARY KEY,
          createdAt INTEGER NOT NULL,
          subtotal REAL NOT NULL,
          discount REAL NOT NULL,
          tax REAL NOT NULL,
          total REAL NOT NULL
        )
        ''');

        // Sale items
        await db.execute('''
        CREATE TABLE sale_items(
          id TEXT PRIMARY KEY,
          saleId TEXT NOT NULL,
          productId TEXT NOT NULL,
          name TEXT NOT NULL,
          qty INTEGER NOT NULL,
          price REAL NOT NULL,
          lineTotal REAL NOT NULL
        )
        ''');
      },
    );
  }
}
