import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/User.dart';
import '../models/Task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;
  final _uuid = Uuid();

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'task_manager.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT,
        password TEXT,
        email TEXT,
        avatar TEXT,
        createdAt TEXT,
        lastActive TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT,
        description TEXT,
        status TEXT,
        priority INTEGER,
        dueDate TEXT,
        createdAt TEXT,
        updatedAt TEXT,
        assignedTo TEXT,
        createdBy TEXT,
        category TEXT,
        attachments TEXT,
        completed INTEGER
      )
    ''');
  }

  // ================= USER CRUD =================

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query('users',
        where: 'username = ?', whereArgs: [username]);
    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  // ================= TASK CRUD =================

  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'createdAt DESC');
    return maps.map((e) => Task.fromMap(e)).toList();
  }

  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ================= TASK FILTERING & SEARCH =================

  Future<List<Task>> searchTasks(String keyword) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$keyword%', '%$keyword%'],
    );
    return maps.map((e) => Task.fromMap(e)).toList();
  }

  Future<List<Task>> filterTasks({String? status, int? priority}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> args = [];

    if (status != null) {
      whereClause += 'status = ?';
      args.add(status);
    }

    if (priority != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'priority = ?';
      args.add(priority);
    }

    final maps = await db.query('tasks',
        where: whereClause.isEmpty ? null : whereClause,
        whereArgs: args);
    return maps.map((e) => Task.fromMap(e)).toList();
  }

  // ================= UTILITY =================

  String generateId() => _uuid.v4();
}
