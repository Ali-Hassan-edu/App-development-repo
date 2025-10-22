import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDB {
  static final AppDB _instance = AppDB._internal();
  factory AppDB() => _instance;
  AppDB._internal();
  Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'pos_app.sqlite');
    return openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT UNIQUE,
        pending_balance REAL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock_qty INTEGER NOT NULL DEFAULT 0,
        reorder_level INTEGER NOT NULL DEFAULT 0,
        category TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        total_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(customer_id) REFERENCES customers(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        line_total REAL NOT NULL,
        FOREIGN KEY(sale_id) REFERENCES sales(id),
        FOREIGN KEY(product_id) REFERENCES products(id)
      );
    ''');

    // For OTP password reset
    await db.execute('''
      CREATE TABLE password_resets(
        phone TEXT PRIMARY KEY,
        otp TEXT NOT NULL,
        expires_at TEXT NOT NULL
      );
    ''');

    await _seedIfEmpty(db);
  }

  FutureOr<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute('ALTER TABLE users ADD COLUMN username TEXT;');
      await db.execute('UPDATE users SET username = phone WHERE username IS NULL;');
      await db.execute('CREATE UNIQUE INDEX IF NOT EXISTS users_username_uqi ON users(username);');
    }
    if (oldV < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS password_resets(
          phone TEXT PRIMARY KEY,
          otp TEXT NOT NULL,
          expires_at TEXT NOT NULL
        );
      ''');
    }
  }

  Future<void> _seedIfEmpty(Database db) async {
    final p = await db.query('products', limit: 1);
    if (p.isEmpty) {
      await db.insert('products', {'name': 'Samsung A14', 'price': 56000, 'stock_qty': 8, 'reorder_level': 2});
      await db.insert('products', {'name': 'Infinix Hot 40', 'price': 48999, 'stock_qty': 14, 'reorder_level': 3});
      await db.insert('products', {'name': 'Tecno Spark 20', 'price': 39999, 'stock_qty': 20, 'reorder_level': 4});
      await db.insert('products', {'name': 'Vivo Y17s', 'price': 62999, 'stock_qty': 6, 'reorder_level': 2});
    }
  }
}
