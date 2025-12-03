import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VictoryVideoScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final String characterName;
  final int levelId;
  final int coins;

  const VictoryVideoScreen({
    super.key,
    required this.onComplete,
    required this.characterName,
    required this.levelId,
    required this.coins,
  });

  @override
  State<VictoryVideoScreen> createState() => _VictoryVideoScreenState();
}

class _VictoryVideoScreenState extends State<VictoryVideoScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isVideoReady = false;
  bool _showIntro = true;

  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    // Configurar animación de fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Iniciar con la intro
    _fadeController.forward();

    // Iniciar la secuencia (espera + carga de video)
    _startSequence();
  }

  void _startSequence() async {
    // Esperar al menos 2 segundos para leer el texto
    final minWait = Future.delayed(const Duration(milliseconds: 2000));
    
    // Iniciar carga del video
    final videoLoad = _initializeVideoController();

    // Esperar a que ambos terminen
    await Future.wait([minWait, videoLoad]);

    if (!mounted) return;

    // Transición suave: Fade out de la intro y fade in del video
    await _fadeController.animateTo(0.0,
        duration: const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() {
      _showIntro = false;
    });

    await _fadeController.animateTo(1.0,
        duration: const Duration(milliseconds: 1000));

    // Reproducir el video
    _videoController.play();

    // Listener para cuando termine el video
    _videoController.addListener(() {
      if (!_isCompleted && 
          _videoController.value.position >= _videoController.value.duration) {
        _isCompleted = true;
        widget.onComplete();
      }
    });
  }

  Future<void> _initializeVideoController() async {
    String videoAsset = 'assets/videos/healer_victory.mp4'; // Default

    // Seleccionar video según el personaje
    if (widget.characterName.contains('Aventurero') ||
        widget.characterName.contains('Adventurer')) {
      videoAsset = 'assets/videos/adventurer_victory.mp4';
    } else if (widget.characterName.contains('Sombra') ||
        widget.characterName.contains('Rogue')) {
      videoAsset = 'assets/videos/rogue_victory.mp4';
    } else if (widget.characterName.contains('Clérigo') ||
        widget.characterName.contains('Healer')) {
      videoAsset = 'assets/videos/healer_victory.mp4';
    }

    _videoController = VideoPlayerController.asset(videoAsset);

    try {
      await _videoController.initialize();
      if (mounted) {
        setState(() {
          _isVideoReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
      // Si falla, nos quedamos en la intro pero habilitamos salir
      if (mounted) {
        setState(() {
          _showIntro = true;
          _isVideoReady = true; // Para mostrar el botón de saltar
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    if (_isVideoReady) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Intro de victoria
          if (_showIntro)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildVictoryIntro(),
            ),

          // Video de victoria
          if (!_showIntro && _isVideoReady)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          // Botón de skip (opcional)
          if (!_showIntro && _isVideoReady)
            Positioned(
              top: 40,
              right: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: TextButton(
                  onPressed: widget.onComplete,
                  style: TextButton.styleFrom(
                    backgroundColor:
                        Colors.black.withAlpha((0.5 * 255).round()),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Saltar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVictoryIntro() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.green.withAlpha((0.3 * 255).round()),
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Texto VICTORIA con efecto brillante
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha((0.2 * 255).round()),
                  border: Border.all(color: Colors.green, width: 4),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withAlpha((0.6 * 255).round()),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '¡VICTORIA!',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.green,
                      letterSpacing: 12,
                      shadows: [
                        Shadow(
                          color: Colors.white,
                          offset: Offset(0, 0),
                          blurRadius: 20,
                        ),
                        Shadow(
                          color: Colors.green,
                          offset: Offset(0, 0),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Información del personaje
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.6 * 255).round()),
                  border: Border.all(
                      color: Colors.white.withAlpha((0.3 * 255).round()),
                      width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.characterName,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Nivel ${widget.levelId} Completado',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 20,
                          color: Colors.green.shade300,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '+${widget.coins}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 24,
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Indicador de carga
              if (!_isVideoReady)
                Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Preparando celebración...',
                      style: TextStyle(
                        color: Colors.white.withAlpha((0.7 * 255).round()),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
