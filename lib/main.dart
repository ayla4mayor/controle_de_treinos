import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Treinos',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        scaffoldBackgroundColor: const Color.fromARGB(255, 242, 190, 190),
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

  final List<Map<String, dynamic>> treinos = [];

  void _addTreino(String nome, String tipo) {
    setState(() {
      treinos.add({
        'nome': nome,
        'tipo': tipo,
        'feito': false,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Treino adicionado com sucesso!'),
      ),
    );
  }

  void _toggleFeito(int index) {
    setState(() {
      treinos[index]['feito'] = !treinos[index]['feito'];
    });
  }

  void _removerTreino(int index) {
    setState(() {
      treinos.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Treino removido'),
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
        onDelete: _removerTreino,
      ),
      AddTreino(onAdd: _addTreino),
      PerfilUsuario(treinos: treinos),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, color: Colors.white),
            SizedBox(width: 8),
            Text('Controle de Treinos'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text('App de Treinos'),
            ),
          ],
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
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
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Controle de Treinos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Organize seus exercícios e acompanhe seu evolução!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListaTreinos extends StatelessWidget {
  final List<Map<String, dynamic>> treinos;
  final Function(int) onToggle;
  final Function(int) onDelete;

  const ListaTreinos({
    super.key,
    required this.treinos,
    required this.onToggle,
    required this.onDelete,
  });

  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'Perna':
        return Icons.directions_run;
      case 'Glúteo':
        return Icons.accessibility_new;
      case 'Posterior':
        return Icons.fitness_center;
      case 'Costas':
        return Icons.accessibility;
      case 'Peito':
        return Icons.favorite;
      case 'Braço':
        return Icons.sports_mma;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getColor(String tipo) {
    switch (tipo) {
      case 'Perna':
        return Colors.blue;
      case 'Glúteo':
        return Colors.purple;
      case 'Posterior':
        return Colors.orange;
      case 'Costas':
        return Colors.green;
      case 'Peito':
        return Colors.red;
      case 'Braço':
        return Colors.teal;
      default:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (treinos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum treino ainda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: treinos.length,
      itemBuilder: (context, index) {
        final treino = treinos[index];

        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: ListTile(
            leading: Icon(
              _getIcon(treino['tipo']),
              color: _getColor(treino['tipo']),
            ),
            title: Text(
              treino['nome'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(treino['tipo']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: treino['feito'],
                  activeColor: Colors.pink,
                  onChanged: (_) => onToggle(index),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
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

class PerfilUsuario extends StatelessWidget {
  final List<Map<String, dynamic>> treinos;

  const PerfilUsuario({
    super.key,
    required this.treinos,
  });

  @override
  Widget build(BuildContext context) {
    int concluidos =
        treinos.where((t) => t['feito'] == true).length;

    int total = treinos.length;

    double progresso =
        total == 0 ? 0 : concluidos / total;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.pink,
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Usuário',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Treinos cadastrados: $total',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Treinos concluídos: $concluidos',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: progresso,
                    minHeight: 10,
                    backgroundColor: Colors.grey,
                    color: Colors.pink,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(progresso * 100).toStringAsFixed(0)}% concluído',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddTreino extends StatefulWidget {
  final Function(String, String) onAdd;

  const AddTreino({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddTreino> createState() => _AddTreinoState();
}

class _AddTreinoState extends State<AddTreino> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomeController =
      TextEditingController();

  String tipoSelecionado = 'Perna';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nomeController,
              decoration: InputDecoration(
                labelText: 'Nome do exercício',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite um exercício';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: tipoSelecionado,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category),
              ),
              items: [
                'Perna',
                'Glúteo',
                'Posterior',
                'Costas',
                'Peito',
                'Braço',
              ]
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(tipo),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  tipoSelecionado = value!;
                });
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      nomeController.text,
                      tipoSelecionado,
                    );

                    nomeController.clear();
                  }
                },
                child: const Text(
                  'Adicionar Treino',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}