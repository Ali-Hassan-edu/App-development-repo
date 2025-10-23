import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class UserRepo {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = p.join(await getDatabasesPath(), 'pos_app.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            phone TEXT UNIQUE,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT UNIQUE,
            previous_due REAL DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            stock INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE sales (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER,
            total REAL,
            created_at TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE sale_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sale_id INTEGER,
            product_name TEXT,
            qty INTEGER,
            price REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE password_resets (
            phone TEXT PRIMARY KEY,
            otp TEXT,
            expires_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldV, newV) async {
        if (oldV < 2) {
          try { await db.execute('ALTER TABLE users ADD COLUMN email TEXT;'); } catch (_) {}
        }
      },
    );
  }

  // -------- AUTH ----------
  static Future<int> register({
    required String username,
    required String phone,
    required String password,
    String? email,
  }) async {
    final db = await database;
    final hashed = sha256.convert(utf8.encode(password)).toString();
    return db.insert(
      'users',
      {
        'username': username,
        'phone': phone,
        'email': (email?.trim().isEmpty ?? true) ? null : email!.trim(),
        'password': hashed
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<Map<String, dynamic>?> login({
    required String username,
    required String phone,
    required String password,
  }) async {
    final db = await database;
    final hashed = sha256.convert(utf8.encode(password)).toString();
    final res = await db.query(
      'users',
      where: 'username = ? AND phone = ? AND password = ?',
      whereArgs: [username, phone, hashed],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  static Future<void> updatePasswordByPhone({
    required String phone,
    required String newPassword,
  }) async {
    final db = await database;
    final hashed = sha256.convert(utf8.encode(newPassword)).toString();
    await db.update('users', {'password': hashed}, where: 'phone = ?', whereArgs: [phone]);
  }

  static Future<Map<String, dynamic>?> userByPhoneOrUsername({
    String? phone,
    String? username,
  }) async {
    final db = await database;
    return (await db.query(
      'users',
      where: '(phone = ? OR username = ?)',
      whereArgs: [phone ?? '', username ?? ''],
      limit: 1,
    ))
        .firstOrNull;
  }

  // -------- CUSTOMERS ----------
  static Future<int> upsertCustomer({
    required String name,
    required String phone,
  }) async {
    final db = await database;
    return db.insert(
      'customers',
      {'name': name, 'phone': phone},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<List<Map<String, dynamic>>> allCustomers() async {
    final db = await database;
    return db.query('customers', orderBy: 'name ASC');
  }

  static Future<Map<String, dynamic>?> customerByPhone(String phone) async {
    final db = await database;
    final res = await db.query('customers', where: 'phone = ?', whereArgs: [phone], limit: 1);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<void> updateCustomerDue(String phone, double newDue) async {
    final db = await database;
    await db.update('customers', {'previous_due': newDue}, where: 'phone = ?', whereArgs: [phone]);
  }

  // -------- PRODUCTS ----------
  static Future<int> addProduct({
    required String name,
    required double price,
    required int stock,
  }) async {
    final db = await database;
    return db.insert('products', {'name': name, 'price': price, 'stock': stock},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> products() async {
    final db = await database;
    return db.query('products', orderBy: 'name ASC');
  }

  static Future<Map<String, dynamic>?> productByName(String name) async {
    final db = await database;
    final rows = await db.query('products',
        where: 'LOWER(name) = ?', whereArgs: [name.toLowerCase()], limit: 1);
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Seed some popular mobile phones if products table is empty.
  static Future<void> seedDummyProductsIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products'),
    ) ??
        0;
    if (count > 0) return;

    const items = [
      {'name': 'iPhone 14', 'price': 230000.0, 'stock': 8},
      {'name': 'iPhone 15', 'price': 290000.0, 'stock': 6},
      {'name': 'Samsung Galaxy S23', 'price': 200000.0, 'stock': 10},
      {'name': 'Samsung A54', 'price': 98000.0, 'stock': 15},
      {'name': 'Infinix Hot 40', 'price': 42000.0, 'stock': 20},
      {'name': 'Tecno Spark 20', 'price': 38000.0, 'stock': 18},
      {'name': 'Xiaomi Redmi Note 12', 'price': 65000.0, 'stock': 12},
      {'name': 'Oppo A78', 'price': 82000.0, 'stock': 9},
      {'name': 'Vivo Y36', 'price': 77000.0, 'stock': 11},
    ];
    final batch = db.batch();
    for (final it in items) {
      batch.insert('products', it, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  static Future<void> adjustStock(String productName, int delta) async {
    final db = await database;
    final rows =
    await db.query('products', where: 'name = ?', whereArgs: [productName], limit: 1);
    if (rows.isEmpty) return;
    final current = (rows.first['stock'] as int?) ?? 0;
    await db.update('products', {'stock': current + delta},
        where: 'id = ?', whereArgs: [rows.first['id']]);
  }

  // -------- SALES ----------
  static Future<int> insertSale({
    required int? customerId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await database;
    final saleId = await db.insert('sales', {
      'customer_id': customerId,
      'total': total,
      'created_at': DateTime.now().toIso8601String(),
    });
    for (final it in items) {
      await db.insert('sale_items', {
        'sale_id': saleId,
        'product_name': it['name'],
        'qty': it['qty'],
        'price': it['price'],
      });
    }
    return saleId;
  }

  static Future<List<Map<String, dynamic>>> salesBetween(DateTime start, DateTime end) async {
    final db = await database;
    final s = start.toIso8601String();
    final e = end.toIso8601String();
    return db.query('sales',
        where: 'created_at >= ? AND created_at <= ?',
        whereArgs: [s, e],
        orderBy: 'created_at DESC');
  }
}

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
