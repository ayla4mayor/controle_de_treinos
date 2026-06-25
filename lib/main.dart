import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// MODEL: Classe para representar um Treino (Melhor prática que Map)
class Treino {
  String nome;
  String tipo;
  bool feito;
  DateTime data;

  Treino({
    required this.nome,
    required this.tipo,
    this.feito = false,
    required this.data,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TrackGym Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pinkAccent,
          secondary: Colors.deepPurpleAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFFFDEEF4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Treino> treinos = []; // Agora usando a classe Treino

  void _addTreino(String nome, String tipo) {
    setState(() {
      treinos.add(Treino(
        nome: nome,
        tipo: tipo,
        data: DateTime.now(),
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Treino adicionado com sucesso!')),
    );
  }

  void _toggleFeito(int index) {
    setState(() {
      treinos[index].feito = !treinos[index].feito;
    });
  }

  // DIALOG DE CONFIRMAÇÃO (Conteúdo de Aula)
  void _confirmarRemocao(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente remover o treino "${treinos[index].nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                treinos.removeAt(index);
              });
              Navigator.pop(context);
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
      ListaTreinos(
        treinos: treinos,
        onToggle: _toggleFeito,
        onDelete: _confirmarRemocao,
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

// --- COMPONENTES STATELESS ---

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

// --- TELAS EXISTENTES MELHORADAS ---

class ListaTreinos extends StatelessWidget {
  final List<Treino> treinos;
  final Function(int) onToggle;
  final Function(int) onDelete;

  const ListaTreinos({
    super.key,
    required this.treinos,
    required this.onToggle,
    required this.onDelete,
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
            leading: CircleAvatar(
              backgroundColor: Colors.pinkAccent.withOpacity(0.2),
              child: const Icon(Icons.fitness_center, color: Colors.pinkAccent),
            ),
            title: Text(treino.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            // USO DE CHIPS (Conteúdo de Aula - PDF 2)
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

// --- NOVA TELA 1: CALCULADORA DE VOLUME ---

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

// --- NOVA TELA 2: DASHBOARD ---

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

class PerfilUsuario extends StatelessWidget {
  final List<Treino> treinos;
  const PerfilUsuario({super.key, required this.treinos});

  @override
  Widget build(BuildContext context) {
    int feitos = treinos.where((t) => t.feito).length;
    double progresso = treinos.isEmpty ? 0 : feitos / treinos.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(radius: 60, backgroundColor: Colors.pinkAccent, child: Icon(Icons.person, size: 60, color: Colors.white)),
          const SizedBox(height: 20),
          const Text('Usuário TrackGym Pro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          CustomCard(
            child: Column(
              children: [
                _buildInfoRow('Total de Exercícios', treinos.length.toString()),
                _buildInfoRow('Concluídos', feitos.toString()),
                _buildInfoRow(
                'Pendentes',
                (treinos.length - feitos).toString(),
                ),
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
