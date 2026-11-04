class Exercicio {
  final int id;
  final String nome;
  final String categoria;
  final String descricao;
  final List<String> musculos;
  final List<String> equipamentos;
  final String? imagemUrl;

  const Exercicio({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.musculos,
    required this.equipamentos,
    this.imagemUrl,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    final translations = (json['translations'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final portugueseTranslation = translations.where(
      (translation) => translation['language'] == 7,
    );
    final translation = portugueseTranslation.isNotEmpty
        ? portugueseTranslation.first
        : (translations.isNotEmpty ? translations.first : <String, dynamic>{});

    final rawImages = json['images'] as List<dynamic>? ?? const [];
    final firstImage = rawImages.whereType<Map<String, dynamic>>().firstOrNull;
    final imageUrl = firstImage?['image'] as String?;

    return Exercicio(
      id: json['id'] as int? ?? 0,
      nome: (translation['name'] as String?)?.trim().isNotEmpty == true
          ? (translation['name'] as String).trim()
          : 'Exercício ${json['id']}',
      categoria: _traduzirCategoria(
        (json['category'] as Map<String, dynamic>?)?['name'] as String? ??
            'Outros',
      ),
      descricao: (translation['description'] as String? ?? '')
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll(RegExp(r'&nbsp;'), ' ')
          .replaceAll(RegExp(r'&amp;'), '&')
          .replaceAll(RegExp(r'&lt;'), '<')
          .replaceAll(RegExp(r'&gt;'), '>')
          .replaceAll(RegExp(r'&quot;'), '"')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim(),
      musculos: _nomes(json['muscles']),
      equipamentos: _nomes(json['equipment']),
      imagemUrl: imageUrl,
    );
  }

  static List<String> _nomes(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map<String, dynamic>>()
        .map((item) => item['name'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
  }

  static String _traduzirCategoria(String categoria) {
    const traducoes = {
      'Abs': 'Abdômen',
      'Arms': 'Braços',
      'Back': 'Costas',
      'Calves': 'Panturrilhas',
      'Chest': 'Peito',
      'Legs': 'Pernas',
      'Shoulders': 'Ombros',
    };
    return traducoes[categoria] ?? categoria;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
