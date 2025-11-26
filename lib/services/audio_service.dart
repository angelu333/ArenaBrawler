import 'package:audioplayers/audioplayers.dart';

/// Servicio para manejar la música de fondo del juego
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  String? _currentTrack;
  bool _isMusicEnabled = true;

  /// Reproducir música de menú en loop
  Future<void> playMenuMusic() async {
    if (!_isMusicEnabled) return;
    
    if (_currentTrack == 'menu') return; // Ya está sonando
    
    await _musicPlayer.stop();
    _currentTrack = 'menu';
    
    await _musicPlayer.setSource(AssetSource('audio/music/menu_music.ogg'));
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.6); // 60% de volumen
    await _musicPlayer.resume();
  }

  /// Reproducir música de pantalla de carga (sin loop)
  Future<void> playLoadingMusic() async {
    if (!_isMusicEnabled) return;
    
    if (_currentTrack == 'loading') return; // Ya está sonando
    
    await _musicPlayer.stop();
    _currentTrack = 'loading';
    
    await _musicPlayer.setSource(AssetSource('audio/music/loading_music.ogg'));
    await _musicPlayer.setReleaseMode(ReleaseMode.release); // Sin loop
    await _musicPlayer.setVolume(0.6);
    await _musicPlayer.resume();
  }

  /// Detener la música
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentTrack = null;
  }

  /// Pausar la música
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  /// Reanudar la música
  Future<void> resumeMusic() async {
    if (_isMusicEnabled) {
      await _musicPlayer.resume();
    }
  }

  /// Activar/desactivar música
  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    }
  }

  /// Cambiar volumen (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    await _musicPlayer.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Liberar recursos
  Future<void> dispose() async {
    await _musicPlayer.dispose();
  }
}
