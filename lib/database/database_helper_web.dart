import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/treino_model.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const String _storageKey = 'trackgym_treinos';

  Future<List<Treino>> listarTreinos() async {
    final preferences = await SharedPreferences.getInstance();
    final content = preferences.getString(_storageKey);
    if (content == null || content.isEmpty) return [];

    final decoded = jsonDecode(content);
    if (decoded is! List<dynamic>) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Treino.fromMap)
        .toList()
      ..sort((a, b) => b.data.compareTo(a.data));
  }

  Future<int> inserirTreino(Treino treino) async {
    final current = await listarTreinos();
    final id = DateTime.now().microsecondsSinceEpoch;
    current.add(treino.copyWith(id: id));
    await _salvar(current);
    return id;
  }

  Future<void> atualizarTreino(Treino treino) async {
    final current = await listarTreinos();
    final index = current.indexWhere((item) => item.id == treino.id);
    if (index < 0) return;
    current[index] = treino;
    await _salvar(current);
  }

  Future<void> removerTreino(int id) async {
    final current = await listarTreinos();
    current.removeWhere((item) => item.id == id);
    await _salvar(current);
  }

  Future<void> _salvar(List<Treino> treinos) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _storageKey,
      jsonEncode(treinos.map((treino) => treino.toMap()).toList()),
    );
  }
}
