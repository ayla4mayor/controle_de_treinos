import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/treino_model.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final databasePath = path.join(await getDatabasesPath(), 'trackgym.db');
    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE treinos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            tipo TEXT NOT NULL,
            feito INTEGER NOT NULL DEFAULT 0,
            data TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<List<Treino>> listarTreinos() async {
    final rows = await (await _db).query('treinos', orderBy: 'data DESC');
    return rows
        .map((row) => Treino.fromMap(Map<String, Object?>.from(row)))
        .toList();
  }

  Future<int> inserirTreino(Treino treino) async {
    final values = treino.toMap()..remove('id');
    return (await _db).insert(
      'treinos',
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizarTreino(Treino treino) async {
    if (treino.id == null) return;
    await (await _db).update(
      'treinos',
      treino.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [treino.id],
    );
  }

  Future<void> removerTreino(int id) async {
    await (await _db).delete('treinos', where: 'id = ?', whereArgs: [id]);
  }
}
