import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  String _nomeUsuario = 'atleta';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final preferences = await SharedPreferences.getInstance();
    final savedName = preferences.getString('nome_usuario');
    if (savedName == null || savedName.trim().isEmpty) {
      await preferences.setString('nome_usuario', 'Atleta');
    } else {
      _nomeUsuario = savedName;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1450));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, animation, __) => const HomePage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFE84478);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF5F8), Color(0xFFF3ECFF)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: pink.withValues(alpha: 0.16),
                      blurRadius: 35,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(Icons.fitness_center, color: pink, size: 54),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'TrackGym Pro',
              style: TextStyle(
                fontSize: 30,
                letterSpacing: -0.8,
                fontWeight: FontWeight.w800,
                color: Color(0xFF241B24),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seu treino, no seu ritmo. Olá, $_nomeUsuario!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF766B75), fontSize: 14),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 23,
              height: 23,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: pink),
            ),
          ],
        ),
      ),
    );
  }
}
