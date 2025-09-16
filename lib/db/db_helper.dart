import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../data/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');
  }

  Future<String> createUser(String email, String password) async {
    try {
      final db = await instance.database;
      
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      await db.insert('users', {
        'id': id,
        'email': email,
        'password': password
      });
      
      return id;
    } catch (e) {
      if (e is DatabaseException) {
        if (e.isUniqueConstraintError()) {
          throw Exception('Email already exists');
        }
      }
      throw Exception('Failed to create user: $e');
    }
  }

  Future<User?> getUser(String email, String password) async {
    try {
      final db = await instance.database;
      final test = await db.query('users');
      print("all data: $test");
      final maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
        limit: 1,
      );
      print("data: ${maps.first}");
      maps.first.forEach((key, value){
        print("$key $value ${value.runtimeType}");
      });
      if (maps.isNotEmpty) {
        return User.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final db = await instance.database;
      final maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check email: $e');
    }
  }

  Future<void> logout(String id) async {
    try {
      final db = await instance.database;
      await db.delete(
        'users',
        where: 'id = ?', // Changed from 'email' to 'id'
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
}