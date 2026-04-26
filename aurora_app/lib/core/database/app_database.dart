import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  static const String _dbName = 'openscale.db';
  static const int _dbVersion = 1;

  Database? _database;

  Database get database {
    final db = _database;
    if (db == null) {
      throw StateError('Database not initialized. Call initialize() first.');
    }
    return db;
  }

  static void initSqflite() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birthday INTEGER NOT NULL,
        body_height REAL NOT NULL,
        gender TEXT NOT NULL,
        initial_weight REAL NOT NULL,
        goal_weight REAL NOT NULL,
        scale_unit TEXT NOT NULL,
        activity_level INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date_time INTEGER NOT NULL,
        comment TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX idx_measurements_user_date
        ON measurements(user_id, date_time)
    ''');

    await db.execute('''
      CREATE TABLE measurement_types (
        id TEXT PRIMARY KEY,
        key TEXT NOT NULL,
        name TEXT,
        unit TEXT NOT NULL,
        color INTEGER NOT NULL DEFAULT 0,
        icon TEXT NOT NULL DEFAULT '',
        is_enabled INTEGER NOT NULL DEFAULT 1,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        is_derived INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        input_type TEXT NOT NULL DEFAULT 'float',
        is_on_right_y_axis INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_measurement_types_key
        ON measurement_types(key)
    ''');

    await db.execute('''
      CREATE TABLE measurement_values (
        id TEXT PRIMARY KEY,
        measurement_id TEXT NOT NULL,
        measurement_type_key TEXT NOT NULL,
        value REAL NOT NULL,
        FOREIGN KEY (measurement_id) REFERENCES measurements(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_measurement_values_measurement
        ON measurement_values(measurement_id)
    ''');

    await db.execute('''
      CREATE TABLE user_goals (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        measurement_type_key TEXT NOT NULL,
        goal_value REAL NOT NULL,
        goal_date INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_user_goals_user
        ON user_goals(user_id)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (int v = oldVersion + 1; v <= newVersion; v++) {
      switch (v) {
        case 1:
          break;
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
