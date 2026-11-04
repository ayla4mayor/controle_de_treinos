import 'package:flutter/material.dart';

import '../models/treino_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.nome,
    required this.treinos,
    required this.onEditarNome,
  });

  final String nome;
  final List<Treino> treinos;
  final ValueChanged<String> onEditarNome;

  @override
  Widget build(BuildContext context) {
    final feitos = treinos.where((treino) => treino.feito).length;
    final pendentes = treinos.length - feitos;
    final progresso = treinos.isEmpty ? 0.0 : feitos / treinos.length;
    final categorias = <String, int>{};
    for (final treino in treinos) {
      categorias.update(treino.tipo, (value) => value + 1, ifAbsent: () => 1);
    }
    final categoriasOrdenadas = categorias.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const Text(
          'Meu perfil',
          style: TextStyle(
            fontSize: 26,
            letterSpacing: -0.7,
            fontWeight: FontWeight.w800,
            color: Color(0xFF241B24),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Seu histórico e suas preferências.',
          style: TextStyle(color: Color(0xFF766B75)),
        ),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFE84478), Color(0xFF9D4CC8)],
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 13),
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF241B24),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _mostrarEditorNome(context),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar nome'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ProfileStat(
                value: '${treinos.length}',
                label: 'Total',
                color: const Color(0xFFE84478),
                icon: Icons.fitness_center_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileStat(
                value: '$feitos',
                label: 'Concluídos',
                color: const Color(0xFF21866B),
                icon: Icons.task_alt_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileStat(
                value: '$pendentes',
                label: 'Pendentes',
                color: const Color(0xFF7656D8),
                icon: Icons.schedule_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progresso geral',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF241B24),
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 11,
                    backgroundColor: const Color(0xFFF0E9ED),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE84478),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  '${(progresso * 100).round()}% da sua lista concluída',
                  style: const TextStyle(color: Color(0xFF766B75)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Treinos por grupo',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF241B24),
                  ),
                ),
                const SizedBox(height: 10),
                if (categoriasOrdenadas.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Adicione exercícios para ver suas estatísticas.',
                      style: TextStyle(color: Color(0xFF766B75)),
                    ),
                  )
                else
                  ...categoriasOrdenadas.map((entry) {
                    final proporcao = treinos.isEmpty
                        ? 0.0
                        : entry.value / treinos.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  color: Color(0xFF766B75),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: proporcao,
                              minHeight: 7,
                              backgroundColor: const Color(0xFFF0E9ED),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF9D4CC8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Center(
          child: Text(
            'TrackGym Pro • seus dados ficam neste dispositivo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Color(0xFF8D818B)),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarEditorNome(BuildContext context) async {
    var nomeDigitado = nome;
    final novoNome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Como devemos chamar você?'),
        content: TextFormField(
          initialValue: nome,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Seu nome',
            prefixIcon: Icon(Icons.person_outline),
          ),
          onChanged: (value) => nomeDigitado = value,
          onFieldSubmitted: (_) =>
              Navigator.pop(dialogContext, nomeDigitado.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, nomeDigitado.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (novoNome != null && novoNome.trim().isNotEmpty) {
      onEditarNome(novoNome.trim());
    }
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 7),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF241B24),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFF766B75)),
            ),
          ],
        ),
      ),
    );
  }
}
