import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';

/// SplashScreen muestra el logo con una animación suave de aparición y escala
/// durante 2.5 segundos al inicio de la aplicación, luego redirige a HomeScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador de animación: duración de 900ms para un efecto sutil y elegante
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Fade-in: de opacidad 0 a 1 con curva easeOut
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    // Escala suave: de 0.88 a 1.0, transmite ligereza sin ser brusca
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    // Inicia la animación al comenzar
    _animController.forward();

    // Temporizador de 2.5 segundos para la transición automática a HomeScreen
    _timer = Timer(const Duration(milliseconds: 2500), _navigateToHome);
  }

  /// Navega a HomeScreen reemplazando la SplashScreen para evitar volver con el botón atrás
  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    // Cancela el temporizador y el controlador para evitar memory leaks
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Image.asset(
                'assets/images/Logo_JelyProductions.png',
                width: 220,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
