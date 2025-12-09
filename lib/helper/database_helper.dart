import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE polls(
        id TEXT PRIMARY KEY,
        title TEXT,
        creatorId TEXT,
        createdAt INTEGER,
        total_votes INTEGER,
        status TEXT
        )
        ''');
        await db.execute('''
        CREATE TABLE poll_options(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pollId TEXT,
        name TEXT,
        imageUrl TEXT,
        votes INTEGER,
        FOREIGN KEY (pollId) REFERENCES polls(id) ON DELETE CASCADE
        )
        ''');
      },
    );
  }

  Future<void> insertPollWithFiles({
    required String pollId,
    required String title,
    required String creatorId,
    required DateTime createdAt,
    required List<String> optionNames,
    required List<File?> optionFiles,
  }) async {
    final db = await database;
    await db.insert('polls', {
      'id': pollId,
      'title': title,
      'creatorId': createdAt.millisecondsSinceEpoch,
      'total_votes': 0,
      'status': 'add',
    });
    for (int i = 0; i < optionNames.length; i++) {
      final filePath = optionFiles[i]?.path ?? '';
      await db.insert('poll_options', {
        'pollId': pollId,
        'name': optionNames[i],
        'imageUrl': filePath,
        'votes': 0,
      });
    }
  }
}
