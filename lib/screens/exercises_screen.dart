import 'package:flutter/material.dart';

import '../models/exercicio_model.dart';
import '../services/wger_api_service.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key, required this.onAdicionar});

  final Future<void> Function(String nome, String tipo) onAdicionar;

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final WgerApiService _api = WgerApiService();
  final TextEditingController _buscaController = TextEditingController();
  late Future<List<Exercicio>> _future;
  String _busca = '';
  String _categoriaSelecionada = 'Todos';

  @override
  void initState() {
    super.initState();
    _future = _api.buscarExercicios();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _api.dispose();
    super.dispose();
  }

  void _tentarNovamente() {
    setState(() => _future = _api.buscarExercicios());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Exercicio>>(
      future: _future,
      builder: (context, snapshot) {
        final exercicios = snapshot.data ?? const <Exercicio>[];
        final categorias = <String>{
          'Todos',
          ...exercicios.map((exercicio) => exercicio.categoria),
        }.toList();
        final filtrados = exercicios.where((exercicio) {
          final correspondeBusca =
              _busca.isEmpty ||
              exercicio.nome.toLowerCase().contains(_busca.toLowerCase()) ||
              exercicio.categoria.toLowerCase().contains(
                _busca.toLowerCase(),
              ) ||
              exercicio.musculos.any(
                (musculo) =>
                    musculo.toLowerCase().contains(_busca.toLowerCase()),
              );
          final correspondeCategoria =
              _categoriaSelecionada == 'Todos' ||
              exercicio.categoria == _categoriaSelecionada;
          return correspondeBusca && correspondeCategoria;
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explorar exercícios',
                    style: TextStyle(
                      fontSize: 26,
                      letterSpacing: -0.7,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF241B24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Encontre um exercício e salve na sua rotina.',
                    style: TextStyle(color: Color(0xFF766B75)),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _buscaController,
                    onChanged: (value) => setState(() => _busca = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Buscar exercício ou músculo',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _busca.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpar busca',
                              onPressed: () {
                                _buscaController.clear();
                                setState(() => _busca = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (snapshot.hasData && categorias.length > 1)
              SizedBox(
                height: 58,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  scrollDirection: Axis.horizontal,
                  children: categorias.map((categoria) {
                    final selecionado = categoria == _categoriaSelecionada;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(categoria),
                        selected: selecionado,
                        onSelected: (_) =>
                            setState(() => _categoriaSelecionada = categoria),
                        selectedColor: const Color(0xFFFFE8F0),
                        labelStyle: TextStyle(
                          color: selecionado
                              ? const Color(0xFFB72C5C)
                              : const Color(0xFF766B75),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            Expanded(child: _conteudo(context, snapshot, filtrados)),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                'Fonte: wger • API pública • CC BY-SA 4.0',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF8D818B)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _conteudo(
    BuildContext context,
    AsyncSnapshot<List<Exercicio>> snapshot,
    List<Exercicio> filtrados,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Carregando catálogo da wger...'),
          ],
        ),
      );
    }
    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFE8F0),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 30,
                  color: Color(0xFFE84478),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Não foi possível carregar os exercícios.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              Text(
                '${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF766B75), fontSize: 12),
              ),
              const SizedBox(height: 15),
              FilledButton.icon(
                onPressed: _tentarNovamente,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (filtrados.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum exercício encontrado para esta busca.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF766B75)),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () async {
        _tentarNovamente();
        try {
          await _future;
        } catch (_) {
          // O FutureBuilder apresenta o erro e a opção de nova tentativa.
        }
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
        itemCount: filtrados.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _ExerciseCard(
          exercise: filtrados[index],
          onTap: () => _mostrarDetalhes(filtrados[index]),
        ),
      ),
    );
  }

  Future<void> _mostrarDetalhes(Exercicio exercicio) async {
    final adicionar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ExerciseDetailsSheet(
        exercise: exercicio,
        onAdicionar: () => Navigator.pop(sheetContext, true),
      ),
    );
    if (adicionar != true || !mounted) return;
    await widget.onAdicionar(
      exercicio.nome,
      _normalizarCategoria(exercicio.categoria),
    );
  }

  String _normalizarCategoria(String categoria) {
    const categorias = {
      'Pernas',
      'Peito',
      'Costas',
      'Braços',
      'Ombros',
      'Abdômen',
      'Cardio',
      'Outros',
    };
    return categorias.contains(categoria) ? categoria : 'Outros';
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.onTap});

  final Exercicio exercise;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final image = exercise.imagemUrl;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              _ExerciseImage(url: image, size: 62),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.nome,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF241B24),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        exercise.categoria,
                        style: const TextStyle(
                          color: Color(0xFFB72C5C),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9B9099)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  const _ExerciseImage({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final canLoad = url != null && !url!.toLowerCase().endsWith('.svg');
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: canLoad
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.fitness_center_rounded,
                color: Color(0xFF7656D8),
              ),
            )
          : const Icon(Icons.fitness_center_rounded, color: Color(0xFF7656D8)),
    );
  }
}

class _ExerciseDetailsSheet extends StatelessWidget {
  const _ExerciseDetailsSheet({
    required this.exercise,
    required this.onAdicionar,
  });

  final Exercicio exercise;
  final VoidCallback onAdicionar;

  @override
  Widget build(BuildContext context) {
    final musculos = exercise.musculos.join(', ');
    final equipamentos = exercise.equipamentos.join(', ');
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFFFFFBFC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 11, bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD8CED5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
                children: [
                  _ExerciseImage(url: exercise.imagemUrl, size: 110),
                  const SizedBox(height: 16),
                  Text(
                    exercise.nome,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: -0.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF241B24),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Chip(
                      label: Text(exercise.categoria),
                      backgroundColor: const Color(0xFFFFE8F0),
                      labelStyle: const TextStyle(
                        color: Color(0xFFB72C5C),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (musculos.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const _DetailLabel(label: 'Músculos'),
                    Text(musculos, style: const TextStyle(height: 1.4)),
                  ],
                  if (equipamentos.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const _DetailLabel(label: 'Equipamentos'),
                    Text(equipamentos, style: const TextStyle(height: 1.4)),
                  ],
                  const SizedBox(height: 14),
                  const _DetailLabel(label: 'Como fazer'),
                  Text(
                    exercise.descricao.isEmpty
                        ? 'A API não disponibilizou uma descrição para este exercício.'
                        : exercise.descricao,
                    style: const TextStyle(
                      color: Color(0xFF615761),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Dados de exercícios fornecidos pela wger. '
                    'Licença CC BY-SA 4.0.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF8D818B)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAdicionar,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar à minha rotina'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLabel extends StatelessWidget {
  const _DetailLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF241B24),
        ),
      ),
    );
  }
}
