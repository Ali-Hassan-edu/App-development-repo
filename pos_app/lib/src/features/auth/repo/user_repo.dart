import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class UserRepo {
  static Database? _db;

  /// Initialize or get existing DB connection
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Create local database
  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'pos_app.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            phone TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  // ---------------------------------------------------------------------------
  // 🧾 USER REGISTRATION
  // ---------------------------------------------------------------------------
  static Future<int> register({
    required String username,
    required String phone,
    required String password,
  }) async {
    final db = await database;
    final hashed = sha256.convert(utf8.encode(password)).toString();

    return await db.insert(
      'users',
      {
        'username': username,
        'phone': phone,
        'password': hashed,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // 🔑 LOGIN
  // ---------------------------------------------------------------------------
  static Future<Map<String, dynamic>?> login({
    required String username,
    required String phone,
    required String password,
  }) async {
    final db = await database;
    final hashed = sha256.convert(utf8.encode(password)).toString();

    final result = await db.query(
      'users',
      where: 'username = ? AND phone = ? AND password = ?',
      whereArgs: [username, phone, hashed],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  // ---------------------------------------------------------------------------
  // 🔍 CHECK USER EXISTS (by phone)
  // ---------------------------------------------------------------------------
  static Future<bool> userExists(String phone) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'phone = ?',
      whereArgs: [phone],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // 🔐 UPDATE PASSWORD (for Forgot Password / OTP recovery)
  // ---------------------------------------------------------------------------
  static Future<void> updatePasswordByPhone({
    required String phone,
    required String newPassword,
  }) async {
    final db = await database;
    final hashed = sha256.convert(utf8.encode(newPassword)).toString();

    await db.update(
      'users',
      {'password': hashed},
      where: 'phone = ?',
      whereArgs: [phone],
    );
  }

  // ---------------------------------------------------------------------------
  // 🧾 GET ALL USERS (for testing/debugging)
  // ---------------------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> allUsers() async {
    final db = await database;
    return db.query('users');
  }
}
