class Treino {
  final int? id;
  final String nome;
  final String tipo;
  final bool feito;
  final DateTime data;

  const Treino({
    this.id,
    required this.nome,
    required this.tipo,
    this.feito = false,
    required this.data,
  });

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

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': nome,
    'tipo': tipo,
    'feito': feito ? 1 : 0,
    'data': data.toIso8601String(),
  };

  factory Treino.fromMap(Map<String, Object?> map) {
    return Treino(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      tipo: map['tipo'] as String,
      feito: map['feito'] == true || map['feito'] == 1,
      data: DateTime.parse(map['data'] as String),
    );
  }
}
