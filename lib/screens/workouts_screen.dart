import 'package:flutter/material.dart';

import '../models/treino_model.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({
    super.key,
    required this.treinos,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final List<Treino> treinos;
  final VoidCallback onAdd;
  final ValueChanged<Treino> onEdit;
  final ValueChanged<Treino> onToggle;
  final ValueChanged<Treino> onDelete;

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _filtro = 'Todos';

  @override
  Widget build(BuildContext context) {
    final feitos = widget.treinos.where((treino) => treino.feito).length;
    final lista = widget.treinos.where((treino) {
      if (_filtro == 'Concluídos') return treino.feito;
      if (_filtro == 'Pendentes') return !treino.feito;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minha rotina',
                      style: TextStyle(
                        fontSize: 26,
                        letterSpacing: -0.7,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF241B24),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monte sua lista e acompanhe cada série.',
                      style: TextStyle(color: Color(0xFF766B75)),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: widget.onAdd,
                tooltip: 'Adicionar treino',
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF241B24),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sports_gymnastics_rounded,
                  color: Color(0xFFFF9ABA),
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '${widget.treinos.length} exercícios na lista',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$feitos/${widget.treinos.length}',
                  style: const TextStyle(
                    color: Color(0xFFFF9ABA),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 60,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            scrollDirection: Axis.horizontal,
            children: ['Todos', 'Pendentes', 'Concluídos'].map((filtro) {
              final selecionado = _filtro == filtro;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(filtro),
                  selected: selecionado,
                  onSelected: (_) => setState(() => _filtro = filtro),
                  selectedColor: const Color(0xFFFFE8F0),
                  labelStyle: TextStyle(
                    color: selecionado
                        ? const Color(0xFFB72C5C)
                        : const Color(0xFF766B75),
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: selecionado
                        ? const Color(0xFFFFD1E0)
                        : const Color(0xFFE9E1E6),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: lista.isEmpty
              ? _EmptyWorkouts(
                  filtered: widget.treinos.isNotEmpty,
                  onAdd: widget.onAdd,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: lista.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final treino = lista[index];
                    return _WorkoutTile(
                      treino: treino,
                      onToggle: () => widget.onToggle(treino),
                      onEdit: () => widget.onEdit(treino),
                      onDelete: () => widget.onDelete(treino),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({
    required this.treino,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final Treino treino;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cor = treino.feito
        ? const Color(0xFF21866B)
        : const Color(0xFFE84478);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        child: Row(
          children: [
            Checkbox(
              value: treino.feito,
              onChanged: (_) => onToggle(),
              activeColor: const Color(0xFF21866B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cor.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_iconePara(treino.tipo), color: cor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        treino.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: treino.feito
                              ? const Color(0xFF8D818B)
                              : const Color(0xFF241B24),
                          decoration: treino.feito
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        treino.tipo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF766B75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opções do treino',
              onSelected: (value) {
                if (value == 'editar') onEdit();
                if (value == 'excluir') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Editar'),
                  ),
                ),
                PopupMenuItem(
                  value: 'excluir',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    title: Text('Excluir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconePara(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'pernas':
      case 'panturrilhas':
        return Icons.directions_run_rounded;
      case 'peito':
        return Icons.accessibility_new_rounded;
      case 'costas':
        return Icons.fitness_center_rounded;
      case 'braços':
      case 'ombros':
        return Icons.sports_martial_arts_rounded;
      case 'cardio':
        return Icons.favorite_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }
}

class _EmptyWorkouts extends StatelessWidget {
  const _EmptyWorkouts({required this.filtered, required this.onAdd});

  final bool filtered;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFE8F0),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 34,
                color: Color(0xFFE84478),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              filtered ? 'Nada por aqui ainda' : 'Sua rotina começa agora',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF241B24),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              filtered
                  ? 'Não há exercícios neste filtro.'
                  : 'Adicione exercícios manualmente ou escolha um no catálogo.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF766B75), height: 1.4),
            ),
            if (!filtered) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Adicionar exercício'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
