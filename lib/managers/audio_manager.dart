import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Singleton pattern
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  // Volumes
  double _musicVolume = 0.7;
  double _sfxVolume = 0.8;

  // États
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
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
    await _sfxPlayer.setVolume(_sfxVolume);

    // Gestion des erreurs audio
    _musicPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped) {
        _currentMusic = null;
      }
    });
  }

  // Jouer de la musique
  Future<void> playMusic(String fileName) async {
    if (!_isMusicEnabled) return;

    if (_currentMusic == fileName) return; // Déjà en cours

    _currentMusic = fileName;
    await _musicPlayer.stop();

    try {
      await _musicPlayer.play(AssetSource('audio/music/$fileName'));
      print('🎵 Musique démarrée: $fileName');
    } catch (e) {
      print('❌ Erreur musique: $e');
      _currentMusic = null;
    }
  }

  // Arrêter la musique
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentMusic = null;
    print('⏹️ Musique arrêtée');
  }

  // Pause/Resume
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
    print('⏸️ Musique en pause');
  }

  Future<void> resumeMusic() async {
    if (_isMusicEnabled && _currentMusic != null) {
      await _musicPlayer.resume();
      print('▶️ Musique reprise');
    }
  }

  // Jouer un effet sonore
  Future<void> playSfx(String fileName) async {
    if (!_isSfxEnabled) return;

    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/$fileName'));
      print('🔊 SFX joué: $fileName');
    } catch (e) {
      print('❌ Erreur SFX: $e');
    }
  }

  // Régler les volumes
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
    print('🔊 Volume musique: ${(volume * 100).toInt()}%');
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    await _sfxPlayer.setVolume(volume);
    print('🔊 Volume SFX: ${(volume * 100).toInt()}%');
  }

  // Activer/Désactiver
  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    print('🎵 Musique ${enabled ? 'activée' : 'désactivée'}');

    if (!enabled) {
      stopMusic();
    } else if (_currentMusic != null) {
      // Rejouer la musique actuelle si elle était en cours
      playMusic(_currentMusic!);
    }
  }

  void toggleSfx(bool enabled) {
    _isSfxEnabled = enabled;
    print('🔊 SFX ${enabled ? 'activés' : 'désactivés'}');
  }

  // Changer de musique avec transition
  Future<void> switchMusic(String? newMusic) async {
    if (newMusic == _currentMusic) return;

    if (newMusic == null) {
      await stopMusic();
      return;
    }

    print('🔄 Changement musique: $_currentMusic → $newMusic');
    await playMusic(newMusic);
  }

  // Vérifier si une musique est en cours
  bool isMusicPlaying() {
    return _currentMusic != null;
  }

  // Nettoyer
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    print('🗑️ AudioManager nettoyé');
  }
}