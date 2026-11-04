import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../models/treino_model.dart';
import 'exercises_screen.dart';
import 'profile_screen.dart';
import 'volume_screen.dart';
import 'workouts_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  int _selectedIndex = 0;
  List<Treino> _treinos = [];
  bool _carregando = true;
  String _nomeUsuario = 'Atleta';
  Object? _erro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final treinos = await _database.listarTreinos();
      if (!mounted) return;
      setState(() {
        _nomeUsuario = preferences.getString('nome_usuario') ?? 'Atleta';
        _treinos = treinos;
        _carregando = false;
        _erro = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _erro = error;
        _carregando = false;
      });
    }
  }

  Future<void> _salvarTreino(
    String nome,
    String tipo, {
    Treino? existente,
  }) async {
    final valor = nome.trim();
    if (valor.isEmpty) return;
    try {
      if (existente == null) {
        await _database.inserirTreino(
          Treino(nome: valor, tipo: tipo, data: DateTime.now()),
        );
      } else {
        await _database.atualizarTreino(
          existente.copyWith(nome: valor, tipo: tipo),
        );
      }
      await _carregarDados();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existente == null
                ? 'Treino adicionado à sua lista.'
                : 'Treino atualizado.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o treino. Tente novamente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _alterarStatus(Treino treino) async {
    await _database.atualizarTreino(treino.copyWith(feito: !treino.feito));
    await _carregarDados();
  }

  Future<void> _excluirTreino(Treino treino) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover treino?'),
        content: Text('“${treino.nome}” será removido da sua lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true || treino.id == null) return;
    await _database.removerTreino(treino.id!);
    await _carregarDados();
  }

  Future<void> _abrirEditor({
    Treino? treino,
    String? nomeInicial,
    String? tipoInicial,
  }) async {
    final formKey = GlobalKey<FormState>();
    var nome = nomeInicial ?? treino?.nome ?? '';
    var tipo = tipoInicial ?? treino?.tipo ?? 'Pernas';
    const tipos = [
      'Pernas',
      'Peito',
      'Costas',
      'Braços',
      'Ombros',
      'Abdômen',
      'Cardio',
      'Outros',
    ];

    final salvar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(treino == null ? 'Novo treino' : 'Editar treino'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nome,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nome do exercício',
                    prefixIcon: Icon(Icons.fitness_center),
                  ),
                  onSaved: (value) => nome = value?.trim() ?? '',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe o nome do exercício'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: tipos.contains(tipo) ? tipo : 'Pernas',
                  decoration: const InputDecoration(
                    labelText: 'Grupo muscular',
                  ),
                  items: tipos
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => tipo = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final form = formKey.currentState!;
                if (!form.validate()) return;
                form.save();
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    if (salvar == true) {
      await _salvarTreino(nome, tipo, existente: treino);
    }
  }

  Future<void> _editarNome(String novoNome) async {
    final nome = novoNome.trim();
    if (nome.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('nome_usuario', nome);
    if (!mounted) return;
    setState(() => _nomeUsuario = nome);
  }

  @override
  Widget build(BuildContext context) {
    final feitos = _treinos.where((treino) => treino.feito).length;
    final paginas = [
      _carregando
          ? const _LoadingView()
          : _erro != null
          ? _ErrorView(onRetry: _carregarDados)
          : _DashboardScreen(
              nome: _nomeUsuario,
              total: _treinos.length,
              feitos: feitos,
              onOpenTreinos: () => setState(() => _selectedIndex = 1),
              onOpenCatalogo: () => setState(() => _selectedIndex = 2),
            ),
      WorkoutsScreen(
        treinos: _treinos,
        onAdd: () => _abrirEditor(),
        onEdit: (treino) => _abrirEditor(treino: treino),
        onToggle: _alterarStatus,
        onDelete: _excluirTreino,
      ),
      ExercisesScreen(
        onAdicionar: (nome, tipo) =>
            _abrirEditor(nomeInicial: nome, tipoInicial: tipo),
      ),
      const VolumeScreen(),
      ProfileScreen(
        nome: _nomeUsuario,
        treinos: _treinos,
        onEditarNome: _editarNome,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: paginas),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            label: 'Treinos',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Exercícios',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Volume',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen({
    required this.nome,
    required this.total,
    required this.feitos,
    required this.onOpenTreinos,
    required this.onOpenCatalogo,
  });

  final String nome;
  final int total;
  final int feitos;
  final VoidCallback onOpenTreinos;
  final VoidCallback onOpenCatalogo;

  @override
  Widget build(BuildContext context) {
    final progresso = total == 0 ? 0.0 : feitos / total;
    final primeiroNome = nome.trim().split(RegExp(r'\s+')).first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TRACKGYM PRO',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 1.7,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE84478),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Olá, $primeiroNome!',
                    style: const TextStyle(
                      fontSize: 27,
                      letterSpacing: -0.8,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF241B24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Vamos avançar no seu treino?',
                    style: TextStyle(color: Color(0xFF766B75)),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.bolt_rounded, color: Color(0xFFE84478)),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE84478), Color(0xFF9D4CC8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE84478).withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Seu progresso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                total == 0
                    ? 'Adicione seu primeiro exercício para começar.'
                    : '$feitos de $total exercícios concluídos',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progresso,
                  minHeight: 9,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(progresso * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Exercícios',
                value: '$total',
                icon: Icons.fitness_center_rounded,
                tint: const Color(0xFFFFE8F0),
                color: const Color(0xFFE84478),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Concluídos',
                value: '$feitos',
                icon: Icons.task_alt_rounded,
                tint: const Color(0xFFEAE5FF),
                color: const Color(0xFF7656D8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'Acesso rápido',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF241B24),
          ),
        ),
        const SizedBox(height: 12),
        _QuickAction(
          icon: Icons.add_rounded,
          title: 'Organizar meus treinos',
          subtitle: 'Adicionar, editar e marcar exercícios',
          onTap: onOpenTreinos,
        ),
        const SizedBox(height: 10),
        _QuickAction(
          icon: Icons.travel_explore_rounded,
          title: 'Explorar exercícios',
          subtitle: 'Catálogo público da API wger',
          onTap: onOpenCatalogo,
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE8FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF7656D8)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Consistência vale mais do que intensidade. Registre cada passo.',
                  style: TextStyle(
                    color: Color(0xFF4C3C78),
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0E9ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF241B24),
            ),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF766B75))),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFFE84478)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF241B24),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF766B75),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9B9099)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storage_rounded, size: 42, color: Color(0xFFE84478)),
          const SizedBox(height: 12),
          const Text(
            'Não foi possível abrir seus treinos.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    ),
  );
}
