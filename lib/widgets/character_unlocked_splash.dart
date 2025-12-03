import 'dart:math';
import 'package:flutter/material.dart';
import 'package:juego_happy/models/character_model.dart';

// Premium Character Unlocked Splash Screen
class CharacterUnlockedSplash extends StatefulWidget {
  final CharacterModel character;

  const CharacterUnlockedSplash({super.key, required this.character});

  @override
  State<CharacterUnlockedSplash> createState() => _CharacterUnlockedSplashState();
}

class _CharacterUnlockedSplashState extends State<CharacterUnlockedSplash>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _particlesController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Particles animation
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Start animations
    _scaleController.forward();
    _rotationController.repeat(reverse: true);
    _particlesController.repeat();
    _glowController.repeat(reverse: true);

    // Auto close after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotationController.dispose();
    _particlesController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Particles background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlesPainter(_particlesController.value),
                );
              },
            ),
          ),

          // Main content with scroll to prevent overflow
          Center(
            child: Container(
              width: 320, // Reducido de 350 a 320
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A0F2E),
                    Color(0xFF0D1B2A),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.yellow.withOpacity( 0.5),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity( 0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity( 0.8),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24), // Reducido de 32 a 24
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Text(
                          '¡DESBLOQUEADO!',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 28, // Reducido de 32 a 28
                            fontWeight: FontWeight.w900,
                            fontFamily: 'GameFont',
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.yellow.withOpacity( 0.8 + _glowController.value * 0.2),
                                blurRadius: 20 + _glowController.value * 10,
                              ),
                              Shadow(
                                color: Colors.orange.withOpacity( 0.6),
                                blurRadius: 40,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20), // Reducido de 30 a 20

                    // Character image with animations
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: AnimatedBuilder(
                              animation: _glowController,
                              builder: (context, child) {
                                return Container(
                                  width: 160, // Reducido de 200 a 160
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.cyan.withOpacity( 0.5 + _glowController.value * 0.3),
                                        blurRadius: 60 + _glowController.value * 20,
                                        spreadRadius: 20,
                                      ),
                                      BoxShadow(
                                        color: Colors.purple.withOpacity( 0.4),
                                        blurRadius: 80,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Container(
                                      color: const Color(0xFF1A0F2E),
                                      padding: const EdgeInsets.all(16), // Reducido de 20 a 16
                                      child: Image.asset(
                                        'assets/images/${widget.character.spriteAsset}',
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 100,
                                            color: Colors.white,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20), // Reducido de 30 a 20

                    // Character name
                    Text(
                      widget.character.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Reducido de 28 a 24
                        fontWeight: FontWeight.bold,
                        fontFamily: 'GameFont',
                        shadows: [
                          Shadow(
                            color: Colors.cyan,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Character description
                    Text(
                      widget.character.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12, // Reducido de 14 a 12
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 16), // Reducido de 20 a 16

                    // Special ability badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.deepPurple],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.yellow, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.character.specialAbilityName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16), // Reducido de 20 a 16

                    // Tap to continue hint
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.5 + _glowController.value * 0.5,
                          child: const Text(
                            'Toca para continuar',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tap to close
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
    );
  }
}

// Particles painter for celebration effect
class _ParticlesPainter extends CustomPainter {
  final double animationValue;
  final Random random = Random(42);

  _ParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final y = (baseY - animationValue * size.height * 1.5) % size.height;
      final radius = random.nextDouble() * 3 + 1;

      // Varied particle colors
      final colorChoice = i % 4;
      Color particleColor;
      if (colorChoice == 0) {
        particleColor = Colors.yellow.withValues(alpha: 0.6);
      } else if (colorChoice == 1) {
        particleColor = Colors.orange.withValues(alpha: 0.5);
      } else if (colorChoice == 2) {
        particleColor = Colors.cyan.withValues(alpha: 0.4);
      } else {
        particleColor = Colors.white.withValues(alpha: 0.5);
      }

      final paint = Paint()
        ..color = particleColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Add glow to some particles
      if (i % 10 == 0) {
        final glowPaint = Paint()
          ..color = particleColor.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), radius * 3, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) => true;
}
