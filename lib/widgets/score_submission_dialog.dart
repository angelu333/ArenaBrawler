import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:juego_happy/services/supabase_service.dart';

class ScoreSubmissionDialog extends StatefulWidget {
  final int score;
  final VoidCallback onClose;

  const ScoreSubmissionDialog({
    super.key,
    required this.score,
    required this.onClose,
  });

  @override
  State<ScoreSubmissionDialog> createState() => _ScoreSubmissionDialogState();
}

class _ScoreSubmissionDialogState extends State<ScoreSubmissionDialog>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isSuccess = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitScore() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = '¡Necesitas un nombre de guerrero!');
      return;
    }

    if (name.length < 3) {
      setState(() => _errorMessage = 'El nombre es muy corto (mín. 3)');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await _supabaseService.savePlayerScore(name, widget.score);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        if (success) {
          _isSuccess = true;
        } else {
          _errorMessage = '¡Ese nombre ya fue tomado por otro héroe!';
        }
      });

      if (success) {
        // Wait a bit to show the success splash before closing
        await Future.delayed(const Duration(milliseconds: 2500));
        widget.onClose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Glassmorphism Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          
          // Content
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isSuccess ? _buildSuccessView() : _buildInputView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputView() {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.cyan.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              '¡VICTORIA!',
              style: TextStyle(
                fontFamily: 'GameFont',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.yellow,
                shadows: [
                  Shadow(
                    color: Colors.orange.withOpacity(0.8),
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Puntuación: ${widget.score}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Input Field
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Ingresa tu nombre',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.cyan, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              ),
            ),
            
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Save Button
            GestureDetector(
              onTap: _isSubmitting ? null : _submitScore,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isSubmitting
                        ? [Colors.grey, Colors.grey.shade700]
                        : [Colors.cyan, Colors.blue],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: (_isSubmitting ? Colors.grey : Colors.cyan).withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'GUARDAR LEYENDA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'GameFont',
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.greenAccent, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withOpacity(0.5),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.greenAccent,
            size: 80,
          ),
          const SizedBox(height: 20),
          const Text(
            '¡GUARDADO!',
            style: TextStyle(
              fontFamily: 'GameFont',
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tu leyenda perdurará...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
