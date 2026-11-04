import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/exercicio_model.dart';

class WgerApiService {
  WgerApiService({http.Client? client}) : _client = client ?? http.Client();

  static final Uri _endpoint = Uri.https('wger.de', '/api/v2/exerciseinfo/', {
    'language': '7',
    'limit': '100',
  });

  final http.Client _client;

  Future<List<Exercicio>> buscarExercicios() async {
    final response = await _client
        .get(_endpoint, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw WgerApiException(
        'A API wger respondeu com o código ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic> ||
        decoded['results'] is! List<dynamic>) {
      throw const WgerApiException(
        'A resposta da API está em formato inválido.',
      );
    }

    return (decoded['results'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(Exercicio.fromJson)
        .where((exercise) => exercise.nome.isNotEmpty)
        .toList();
  }

  void dispose() => _client.close();
}

class WgerApiException implements Exception {
  final String message;

  const WgerApiException(this.message);

  @override
  String toString() => message;
}
