import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrackGymApp());
}

class TrackGymApp extends StatelessWidget {
  const TrackGymApp({super.key});

  static const Color _pink = Color(0xFFE84478);
  static const Color _purple = Color(0xFF7656D8);

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _pink,
      primary: _pink,
      secondary: _purple,
      surface: const Color(0xFFFFFBFC),
    );

    return MaterialApp(
      title: 'TrackGym Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF7F4F6),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF7F4F6),
          foregroundColor: Color(0xFF241B24),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF0E9ED)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F5F7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFF0E9ED)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _pink, width: 1.5),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 68,
          backgroundColor: Colors.white,
          indicatorColor: _pink.withValues(alpha: 0.13),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
