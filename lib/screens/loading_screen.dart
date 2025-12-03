import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';
<<<<<<< HEAD
=======
import 'intro_video_screen.dart';
>>>>>>> master
import 'package:juego_happy/services/audio_service.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  double _progress = 0.0;
  String _loadingText = 'Cargando...';
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    // Iniciar música de carga
    _audioService.playLoadingMusic();

    // Configurar animación de fade-in para el logo
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Configurar animación de rebote y escala
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animación de escala (crece y se encoge ligeramente)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_bounceController);

    // Animación de rebote vertical
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -15, end: 0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_bounceController);

    // Iniciar animaciones
    _fadeController.forward();
    _bounceController.forward().then((_) {
      // Repetir la animación de rebote
      _bounceController.repeat(reverse: false);
    });

    // Iniciar carga
    _startLoading();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    // No detenemos la música aquí porque queremos que la transición sea suave
    // o que el HomeScreen se encargue de cambiarla
    super.dispose();
  }

  // Función que simula la carga con progreso dinámico
  Future<void> _startLoading() async {
    // Pausa inicial para que se vea el logo
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulamos la carga de diferentes assets con más emoción
    await _loadWithProgress('Preparando guerreros...', 0.25, 100);
    await _loadWithProgress('Construyendo arena...', 0.50, 120);
    await _loadWithProgress('Afilando armas...', 0.75, 100);
    await _loadWithProgress('¡Casi listo!', 0.95, 80);
    await _loadWithProgress('¡A PELEAR!', 1.0, 60);

    // Pausa dramática antes de navegar
    await Future.delayed(const Duration(milliseconds: 800));

    // Navegar a la pantalla principal
    if (mounted) {
      Navigator.pushReplacement(
        context,
<<<<<<< HEAD
        MaterialPageRoute(builder: (context) => const HomeScreen()),
=======
        MaterialPageRoute(builder: (context) => const IntroVideoScreen()),
>>>>>>> master
      );
    }
  }

  Future<void> _loadWithProgress(
      String text, double targetProgress, int delayMs) async {
    setState(() {
      _loadingText = text;
    });

    // Animación más lenta y dramática del progreso
    while (_progress < targetProgress) {
      await Future.delayed(Duration(milliseconds: delayMs));
      if (mounted) {
        setState(() {
          _progress += 0.01; // Incremento más pequeño para más suavidad
          if (_progress > targetProgress) _progress = targetProgress;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo de la arena
          Image.asset(
            'assets/images/arena_background.png',
            fit: BoxFit.cover,
          ),
          // Capa oscura semitransparente para mejor legibilidad
          Container(
<<<<<<< HEAD
            color: Colors.black.withValues(alpha: 0.4),
=======
            color: Colors.black.withOpacity( 0.4),
>>>>>>> master
          ),
          // Contenido de la pantalla de carga
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo animado con fade-in, rebote y escala
                  AnimatedBuilder(
                    animation: _bounceController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Image.asset(
                              'assets/images/logo_arena_brawler.png',
                              width: MediaQuery.of(context).size.width * 0.6,
                              height: 140,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const Spacer(flex: 3),
                  // Barra de progreso y texto en la parte inferior
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Texto de carga con porcentaje - estilo caricaturizado
                        Text(
                          '$_loadingText ${(_progress * 100).toInt()}%',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            shadows: [
                              const Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(2, 2),
                              ),
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.orange.withValues(alpha: 0.5),
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Barra de progreso estilo caricatura
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black87,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Stack(
                              children: [
                                // Fondo con gradiente
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey[900]!,
                                        Colors.grey[800]!,
                                      ],
                                    ),
                                  ),
                                ),
                                // Barra de progreso con gradiente
                                FractionallySizedBox(
                                  widthFactor: _progress,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF6B00), // Naranja
                                          Color(0xFFFFD700), // Dorado
                                          Color(0xFFFFB800), // Amarillo
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFFFFB800),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Brillo superior
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.5],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
