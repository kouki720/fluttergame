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

  // Initialisation
  Future<void> init() async {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  // Musique de fond
  Future<void> playMusic(String fileName) async {
    if (!_isMusicEnabled) return;
    if (_currentMusic == fileName) return;

    _currentMusic = fileName;
    await _musicPlayer.stop();
    await _musicPlayer.play(AssetSource('audio/music/$fileName'));
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _currentMusic = null;
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_isMusicEnabled && _currentMusic != null) {
      await _musicPlayer.resume();
    }
  }

  // Effets sonores
  Future<void> playSfx(String fileName) async {
    if (!_isSfxEnabled) return;
    await _sfxPlayer.play(AssetSource('audio/sfx/$fileName'));
  }

  // Configuration audio
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    await _sfxPlayer.setVolume(volume);
  }

  void toggleMusic(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled) {
      stopMusic();
    } else if (_currentMusic != null) {
      playMusic(_currentMusic!);
    }
  }

  void toggleSfx(bool enabled) {
    _isSfxEnabled = enabled;
  }

  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}