import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/treino_model.dart';

class DatabaseHelper {
  // Singleton: garante uma única instância do banco em todo o app
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // No Linux e no Windows Desktop, o sqflite não tem implementação nativa.
    // Nesses casos, usamos o sqflite_common_ffi (baseado em SQLite puro).
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final path = join(await getDatabasesPath(), 'trackgym.db');
    return await openDatabase(
  path,
  version: 2,
  onCreate: _onCreate,
);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE treinos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT NOT NULL,
        feito INTEGER NOT NULL,
        data TEXT NOT NULL
      )
    ''');
  }

  // ---------- CREATE ----------
  Future<int> inserirTreino(Treino treino) async {
    final db = await database;
    return await db.insert(
      'treinos',
      treino.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------- READ (todos) ----------
  Future<List<Treino>> listarTreinos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('treinos', orderBy: 'data DESC');
    return maps.map((m) => Treino.fromMap(m)).toList();
  }

  // ---------- READ (por id) ----------
  Future<Treino?> buscarTreinoPorId(int id) async {
    final db = await database;
    final maps = await db.query('treinos', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Treino.fromMap(maps.first);
  }

  // ---------- UPDATE ----------
  Future<int> atualizarTreino(Treino treino) async {
    final db = await database;
    return await db.update(
      'treinos',
      treino.toMap(),
      where: 'id = ?',
      whereArgs: [treino.id],
    );
  }

  // ---------- DELETE ----------
  Future<int> removerTreino(int id) async {
    final db = await database;
    return await db.delete('treinos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> fecharBanco() async {
    final db = await database;
    db.close();
  }
}
