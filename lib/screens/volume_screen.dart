import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VolumeScreen extends StatefulWidget {
  const VolumeScreen({super.key});

  @override
  State<VolumeScreen> createState() => _VolumeScreenState();
}

class _VolumeScreenState extends State<VolumeScreen> {
  final _seriesController = TextEditingController(text: '3');
  final _repeticoesController = TextEditingController(text: '10');
  final _cargaController = TextEditingController(text: '20');
  double? _volume;

  @override
  void dispose() {
    _seriesController.dispose();
    _repeticoesController.dispose();
    _cargaController.dispose();
    super.dispose();
  }

  void _calcular() {
    final series = int.tryParse(_seriesController.text) ?? 0;
    final repeticoes = int.tryParse(_repeticoesController.text) ?? 0;
    final carga =
        double.tryParse(_cargaController.text.replaceAll(',', '.')) ?? 0;
    if (series <= 0 || repeticoes <= 0 || carga <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha os três campos com valores maiores que zero.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _volume = series * repeticoes * carga);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        const Text(
          'Calculadora',
          style: TextStyle(
            fontSize: 26,
            letterSpacing: -0.7,
            fontWeight: FontWeight.w800,
            color: Color(0xFF241B24),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Acompanhe o volume total do exercício.',
          style: TextStyle(color: Color(0xFF766B75)),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(19),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE8FF),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.functions_rounded, color: Color(0xFF7656D8)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Volume = séries × repetições × carga (kg)',
                  style: TextStyle(
                    color: Color(0xFF4C3C78),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _NumberInput(
                  label: 'Séries',
                  hint: 'Ex.: 3',
                  controller: _seriesController,
                  suffix: 'séries',
                  decimal: false,
                ),
                const SizedBox(height: 13),
                _NumberInput(
                  label: 'Repetições por série',
                  hint: 'Ex.: 10',
                  controller: _repeticoesController,
                  suffix: 'reps',
                  decimal: false,
                ),
                const SizedBox(height: 13),
                _NumberInput(
                  label: 'Carga',
                  hint: 'Ex.: 20',
                  controller: _cargaController,
                  suffix: 'kg',
                  decimal: true,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _calcular,
                    icon: const Icon(Icons.calculate_rounded),
                    label: const Text('Calcular volume'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _volume == null
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : Container(
                  key: const ValueKey('result'),
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7656D8), Color(0xFF9D4CC8)],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'VOLUME TOTAL',
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_volume!.toStringAsFixed(_volume! % 1 == 0 ? 0 : 1)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          letterSpacing: -0.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'de carga movimentada neste exercício',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _NumberInput extends StatelessWidget {
  const _NumberInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.suffix,
    required this.decimal,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String suffix;
  final bool decimal;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          decimal ? RegExp(r'^\d*[,.]?\d*$') : RegExp(r'\d*'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
      ),
    );
  }
}
