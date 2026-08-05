import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/treino_model.dart';
import '../database/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final DatabaseHelper _db = DatabaseHelper();
  List<Treino> treinos = [];
  bool _carregando = true;
  String? _erro;

 @override
void initState() {
  super.initState();
  _carregarTreinos();
}

  // ---------- READ ----------
  Future<void> _carregarTreinos() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final lista = await _db.listarTreinos();
      setState(() {
        treinos = lista;
        _carregando = false;
      });
    } catch (e) {
      setState(() {
        _erro = e.toString();
        _carregando = false;
      });
    }
  }

  // ---------- CREATE ----------
  Future<void> _addTreino(String nome, String tipo) async {
    final novo = Treino(nome: nome, tipo: tipo, data: DateTime.now());
    await _db.inserirTreino(novo);
    await _carregarTreinos();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino adicionado com sucesso!')),
    );
  }

  // ---------- UPDATE (status feito) ----------
  Future<void> _toggleFeito(int index) async {
    final treino = treinos[index];
    final atualizado = treino.copyWith(feito: !treino.feito);
    await _db.atualizarTreino(atualizado);
    await _carregarTreinos();
  }

  // ---------- UPDATE (editar nome/tipo) ----------
  Future<void> _editarTreino(int index) async {
    final treino = treinos[index];
    final nomeController = TextEditingController(text: treino.nome);
    String tipoSelecionado = treino.tipo;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar Treino'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tipoSelecionado,
                items: ['Perna', 'Peito', 'Costas', 'Braço', 'Ombro', 'Cardio']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setStateDialog(() => tipoSelecionado = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final atualizado = treino.copyWith(
                  nome: nomeController.text,
                  tipo: tipoSelecionado,
                );
                await _db.atualizarTreino(atualizado);
                Navigator.pop(context);
                await _carregarTreinos();
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- DELETE ----------
  void _confirmarRemocao(int index) {
    final treino = treinos[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente remover o treino "${treino.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () async {
              await _db.removerTreino(treino.id!);
              Navigator.pop(context);
              await _carregarTreinos();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Treino removido')),
              );
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TelaInicial(),
      _carregando
          ? const Center(child: CircularProgressIndicator())
          : _erro != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.redAccent, size: 40),
                        const SizedBox(height: 12),
                        Text('Erro ao carregar treinos:\n$_erro',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _carregarTreinos,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListaTreinos(
              treinos: treinos,
              onToggle: _toggleFeito,
              onDelete: _confirmarRemocao,
              onEdit: _editarTreino,
            ),
      AddTreino(onAdd: _addTreino),
      const CalculadoraVolume(),
      EstatisticasTreino(treinos: treinos),
      PerfilUsuario(treinos: treinos),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center),
            SizedBox(width: 10),
            Text('TrackGym Pro'),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Treinos'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Novo'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'Volume'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Icon(Icons.fitness_center, size: 100, color: Colors.pinkAccent),
            ),
            SizedBox(height: 20),
            Text(
              'Bem-vindo ao TrackGym Pro',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Organize seus treinos e acompanhe sua evolução diariamente!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  const CustomCard({super.key, required this.child, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class ListaTreinos extends StatelessWidget {
  final List<Treino> treinos;
  final Function(int) onToggle;
  final Function(int) onDelete;
  final Function(int) onEdit;

  const ListaTreinos({
    super.key,
    required this.treinos,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (treinos.isEmpty) {
      return const Center(child: Text('Nenhum treino cadastrado.'));
    }

    return ListView.builder(
      itemCount: treinos.length,
      itemBuilder: (context, index) {
        final treino = treinos[index];
        return CustomCard(
          child: ListTile(
            onTap: () => onEdit(index),
            leading: CircleAvatar(
              backgroundColor: Colors.pinkAccent.withOpacity(0.2),
              child: const Icon(Icons.fitness_center, color: Colors.pinkAccent),
            ),
            title: Text(treino.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                children: [
                  Chip(
                    label: Text(treino.tipo, style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.pinkAccent.withOpacity(0.1),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: treino.feito,
                  onChanged: (_) => onToggle(index),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
                  onPressed: () => onEdit(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => onDelete(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddTreino extends StatefulWidget {
  final Function(String, String) onAdd;
  const AddTreino({super.key, required this.onAdd});

  @override
  State<AddTreino> createState() => _AddTreinoState();
}

class _AddTreinoState extends State<AddTreino> {
  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  String tipoSelecionado = 'Perna';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text('Novo Exercício', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextFormField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              items: ['Perna', 'Peito', 'Costas', 'Braço', 'Ombro', 'Cardio']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => tipoSelecionado = v!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onAdd(nomeController.text, tipoSelecionado);
                  nomeController.clear();
                }
              },
              child: const Text('Salvar Treino'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculadoraVolume extends StatefulWidget {
  const CalculadoraVolume({super.key});

  @override
  State<CalculadoraVolume> createState() => _CalculadoraVolumeState();
}

class _CalculadoraVolumeState extends State<CalculadoraVolume> {
  final seriesController = TextEditingController(text: '3');
  final repsController = TextEditingController(text: '10');
  final cargaController = TextEditingController(text: '20');
  double _volumeTotal = 0;
  bool _showResult = false;

  void _calcular() {
    double s = double.tryParse(seriesController.text) ?? 0;
    double r = double.tryParse(repsController.text) ?? 0;
    double c = double.tryParse(cargaController.text) ?? 0;

    setState(() {
      _volumeTotal = s * r * c;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text('Calculadora de Volume', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildInput('Séries', seriesController)),
              const SizedBox(width: 10),
              Expanded(child: _buildInput('Reps', repsController)),
              const SizedBox(width: 10),
              Expanded(child: _buildInput('Carga (kg)', cargaController)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _calcular,
            icon: const Icon(Icons.calculate),
            label: const Text('Calcular Volume'),
          ),
          const SizedBox(height: 30),
          AnimatedScale(
            scale: _showResult ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            child: AnimatedOpacity(
              opacity: _showResult ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    const Text('Volume Total do Exercício', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    Text('${_volumeTotal.toStringAsFixed(1)} kg',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Icon(Icons.trending_up, color: Colors.white, size: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }
}

class EstatisticasTreino extends StatelessWidget {
  final List<Treino> treinos;
  const EstatisticasTreino({super.key, required this.treinos});

  @override
  Widget build(BuildContext context) {
    Map<String, int> contagem = {};
    for (var t in treinos) {
      contagem[t.tipo] = (contagem[t.tipo] ?? 0) + 1;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo por Categoria', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.pinkAccent.withOpacity(0.1)),
              columns: const [
                DataColumn(label: Text('Categoria')),
                DataColumn(label: Text('Quantidade'), numeric: true),
                DataColumn(label: Text('% Total'), numeric: true),
              ],
              rows: contagem.entries.map((e) {
                double perc = treinos.isEmpty ? 0 : (e.value / treinos.length) * 100;
                return DataRow(cells: [
                  DataCell(Text(e.key)),
                  DataCell(Text(e.value.toString())),
                  DataCell(Text('${perc.toStringAsFixed(1)}%')),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),
          const Text('Distribuição Visual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...contagem.entries.map((e) {
            double widthFactor = treinos.isEmpty ? 0 : e.value / treinos.length;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.key),
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    height: 12,
                    width: (MediaQuery.of(context).size.width - 40) * widthFactor,
                    decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class PerfilUsuario extends StatefulWidget {
  final List<Treino> treinos;
  const PerfilUsuario({super.key, required this.treinos});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  String nome = 'Usuário TrackGym Pro';

  @override
  void initState() {
    super.initState();
    _carregarNome();
  }

  // ---------- SharedPreferences: leitura ----------
  Future<void> _carregarNome() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nome = prefs.getString('nome_usuario') ?? nome;
    });
  }

  // ---------- SharedPreferences: escrita ----------
  Future<void> _editarNome() async {
    final controller = TextEditingController(text: nome);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Nome'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('nome_usuario', controller.text);
              setState(() => nome = controller.text);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treinos = widget.treinos;
    int feitos = treinos.where((t) => t.feito).length;
    double progresso = treinos.isEmpty ? 0 : feitos / treinos.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(radius: 60, backgroundColor: Colors.pinkAccent, child: Icon(Icons.person, size: 60, color: Colors.white)),
          const SizedBox(height: 20),
          Text(nome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          TextButton.icon(
            onPressed: _editarNome,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Editar nome'),
          ),
          const SizedBox(height: 10),
          CustomCard(
            child: Column(
              children: [
                _buildInfoRow('Total de Exercícios', treinos.length.toString()),
                _buildInfoRow('Concluídos', feitos.toString()),
                _buildInfoRow('Pendentes', (treinos.length - feitos).toString()),
                const Divider(),
                const SizedBox(height: 10),
                const Text('Seu Progresso Atual'),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: progresso, minHeight: 12, borderRadius: BorderRadius.circular(10)),
                const SizedBox(height: 10),
                Text('${(progresso * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontSize: 16)), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
      ),
    );
  }
}
