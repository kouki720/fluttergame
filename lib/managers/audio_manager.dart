// managers/audio_manager.dart
import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;
  bool _isMusicEnabled = true;
  bool _isSfxEnabled = true;
  String? _currentMusic;

  // Getters
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;
  bool get isMusicEnabled => _isMusicEnabled;
  bool get isSfxEnabled => _isSfxEnabled;
  String? get currentMusic => _currentMusic;

  // Initialisation
  Future<void> init() async {
    try {
      _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);
      await _sfxPlayer.setVolume(_sfxVolume);

      _musicPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.stopped) {
          _currentMusic = null;
        }
      });

      print('✅ AudioManager initialisé avec succès');
    } catch (e) {
      print('❌ Erreur initialisation AudioManager: $e');
    }
  }

  // Musique
  Future<void> playMusic(String fileName) async {
    if (!_isMusicEnabled) {
      print('🔇 Musique désactivée - Ignorer: $fileName');
      return;
    }

    try {
      await _musicPlayer.stop();
      await Future.delayed(const Duration(milliseconds: 100));

      _currentMusic = fileName;
      await _musicPlayer.play(AssetSource('audio/music/$fileName'));
      print('🎵 Musique démarrée: $fileName');

    } catch (e) {
      print('❌ Erreur musique "$fileName": $e');

      try {
        await _musicPlayer.play(AssetSource('audio/$fileName'));
        print('🎵 Musique démarrée (fallback 1): audio/$fileName');
      } catch (e2) {
        print('❌ Erreur fallback 1: $e2');

        try {
          await _musicPlayer.play(AssetSource(fileName));
          print('🎵 Musique démarrée (fallback 2): $fileName');
        } catch (e3) {
          print('❌ Erreur fallback 2: $e3');
          _currentMusic = null;
        }
      }
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
      _currentMusic = null;
      print('⏹️ Musique arrêtée');
    } catch (e) {
      print('❌ Erreur arrêt musique: $e');
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
      print('⏸️ Musique mise en pause');
    } catch (e) {
      print('❌ Erreur pause musique: $e');
    }
  }

  Future<void> resumeMusic() async {
    if (_isMusicEnabled && _currentMusic != null) {
      try {
        await _musicPlayer.resume();
        print('▶️ Musique reprise');
      } catch (e) {
        print('❌ Erreur reprise musique: $e');
      }
    }
  }

  // Sons spécifiques
  Future<void> playJumpSfx() async {
    print('🔊 Lecture son de saut');
    await _playSfx('jump.mp3');
  }

  Future<void> playSwordAttackSfx() async {
    print('🔊 Lecture son d\'attaque épée');
    await _playSfx('sword_attack.mp3');
  }

  Future<void> playFlameAttackSfx() async {
    print('🔊 Lecture son d\'attaque flamme');
    await _playSfx('flame_attack.mp3');
  }

  Future<void> playButtonSfx() async {
    print('🔊 Lecture son de bouton');
    await _playSfx('button_click.mp3');
  }

  // Méthode privée pour jouer les SFX
  Future<void> _playSfx(String fileName) async {
    if (!_isSfxEnabled) {
      print('🔇 SFX désactivés - Ignorer: $fileName');
      return;
    }

    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/$fileName'));
      print('🔊 SFX joué avec succès: $fileName');
    } catch (e) {
      print('❌ Erreur SFX "$fileName": $e');

      try {
        await _sfxPlayer.play(AssetSource('audio/$fileName'));
        print('🔊 SFX joué (fallback 1): audio/$fileName');
      } catch (e2) {
        print('❌ Erreur fallback 1 SFX: $e2');

        try {
          await _sfxPlayer.play(AssetSource(fileName));
          print('🔊 SFX joué (fallback 2): $fileName');
        } catch (e3) {
          print('❌ Erreur fallback 2 SFX: $e3');
        }
      }
    }
  }

  // Méthode générique pour SFX
  Future<void> playSfx(String fileName) async {
    print('🔊 Lecture SFX générique: $fileName');
    await _playSfx(fileName);
  }

  // Régler les volumes
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
    print('🔊 Volume musique réglé à: ${(volume * 100).toInt()}%');
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    await _sfxPlayer.setVolume(volume);
    print('🔊 Volume SFX réglé à: ${(volume * 100).toInt()}%');
  }

  // Activer/Désactiver
  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    print('🎵 Musique ${enabled ? 'activée' : 'désactivée'}');

    if (!enabled) {
      stopMusic();
    } else if (_currentMusic != null) {
      playMusic(_currentMusic!);
    }
  }

  void toggleSfx(bool enabled) {
    _isSfxEnabled = enabled;
    print('🔊 SFX ${enabled ? 'activés' : 'désactivés'}');
  }

  // Nettoyer
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    print('🗑️ AudioManager nettoyé');
  }
}