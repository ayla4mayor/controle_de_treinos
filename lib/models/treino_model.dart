class Treino {
  int? id;
  String nome;
  String tipo;
  bool feito;
  DateTime data;

  Treino({
    this.id,
    required this.nome,
    required this.tipo,
    this.feito = false,
    required this.data,
  });

  // Converte um Treino em Map (para salvar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'feito': feito ? 1 : 0,
      'data': data.toIso8601String(),
    };
  }

  // Cria um Treino a partir de um Map (vindo do SQLite)
  factory Treino.fromMap(Map<String, dynamic> map) {
    return Treino(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      tipo: map['tipo'] as String,
      feito: (map['feito'] as int) == 1,
      data: DateTime.parse(map['data'] as String),
    );
  }

  Treino copyWith({
    int? id,
    String? nome,
    String? tipo,
    bool? feito,
    DateTime? data,
  }) {
    return Treino(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      feito: feito ?? this.feito,
      data: data ?? this.data,
    );
  }
}
