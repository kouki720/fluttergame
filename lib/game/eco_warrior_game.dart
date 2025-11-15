// game/eco_warrior_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'parallax_background.dart';
import '../components/ui/joystick.dart';
import '../components/player/player.dart';
import '../managers/audio_manager.dart';
import '../managers/enemy_manager.dart';

class EcoWarriorGame extends FlameGame with HasCollisionDetection {
  // Composants du jeu
  late final ParallaxBackground parallaxBackground;
  late final GameJoystickComponent joystick;
  late final Player player;
  late final EnemyManager enemyManager;

  // État du jeu
  int _score = 0;
  int _gameTimer = 180;
  bool isGameRunning = true;
  double _timeAccumulator = 0.0;

  // Callbacks pour l'UI
  VoidCallback? onTimeUpdate;
  VoidCallback? onGameOver;
  VoidCallback? onScoreUpdate;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    print('🎮 Initialisation du jeu EcoWarrior avec Flame 1.33.0...');

    // Initialiser l'audio manager
    AudioManager();

    // ✅ CORRECTION: Initialiser le callback Game Over
    onGameOver = _handleGameOver;

    // Charger les composants dans l'ordre
    await _loadParallaxBackground();
    await _loadPlayer();
    await _loadJoystick();
    await _loadEnemyManager();

    // Activer le HUD
    overlays.add('hudOverlay');

    print('✅ Jeu initialisé avec ${children.length} composants');
    print('📏 Taille de l\'écran: $size');
    print('🎮 Position joueur: ${player.position}');
    print('👹 Nombre d\'ennemis: ${enemyManager.enemyCount}');
  }

  Future<void> _loadParallaxBackground() async {
    parallaxBackground = ParallaxBackground();
    await add(parallaxBackground);
    print('🌄 Background parallax chargé');
  }

  Future<void> _loadPlayer() async {
    player = Player(
      position: Vector2(size.x / 4, size.y - 150),
    );
    await add(player);
    print('🎮 Joueur chargé à la position: ${player.position}');
  }

  Future<void> _loadJoystick() async {
    joystick = GameJoystickComponent(
      onDirectionChanged: _handleDirectionChange,
      onJump: _handleJump,
      onAction: _handleAction,
    );
    await add(joystick);
    print('🕹️ Joystick chargé');
  }

  Future<void> _loadEnemyManager() async {
    enemyManager = EnemyManager();
    await add(enemyManager);

    // Attendre que tout soit chargé avant de générer les ennemis
    await Future.delayed(Duration(milliseconds: 200));

    // Générer les ennemis pour le stage 1
    enemyManager.spawnEnemiesForStage(1, size);

    print('👹 EnemyManager chargé avec ${enemyManager.enemyCount} ennemis');
  }

  void _handleDirectionChange(GameJoystickDirection direction) {
    if (!isGameRunning) return;

    switch (direction) {
      case GameJoystickDirection.left:
        player.setMovementDirection(-1.0);
        parallaxBackground.updateParallax(direction);
        break;
      case GameJoystickDirection.right:
        player.setMovementDirection(1.0);
        parallaxBackground.updateParallax(direction);
        break;
      case GameJoystickDirection.idle:
        player.setMovementDirection(0.0);
        parallaxBackground.updateParallax(direction);
        break;
      case GameJoystickDirection.jump:
      // Géré séparément dans _handleJump
        break;
    }
  }

  void _handleJump() {
    if (!isGameRunning) return;
    player.jump();
  }

  void _handleAction(GameAction action) {
    if (!isGameRunning) return;

    switch (action) {
      case GameAction.swordAttack:
        player.swordAttack();
        break;
      case GameAction.flameAttack:
        player.flameAttack();
        break;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isGameRunning) return;

    // Mettre à jour la position du joueur pour l'EnemyManager
    enemyManager.updatePlayerPosition(player.position);

    // Mise à jour du timer
    if (_gameTimer > 0) {
      _timeAccumulator += dt;
      if (_timeAccumulator >= 1.0) {
        _timeAccumulator = 0.0;
        _gameTimer--;
        onTimeUpdate?.call();

        if (_gameTimer <= 0) {
          _handleTimeOut();
        }
      }
    }

    // Limites de l'écran pour le joueur
    _checkPlayerBounds();
  }

  void _checkPlayerBounds() {
    // Empêcher le joueur de sortir de l'écran
    final halfPlayerWidth = player.size.x / 2;

    if (player.position.x < halfPlayerWidth) {
      player.position.x = halfPlayerWidth;
    } else if (player.position.x > size.x - halfPlayerWidth) {
      player.position.x = size.x - halfPlayerWidth;
    }
  }

  void _handleTimeOut() {
    print('⏰ TEMPS ÉCOULÉ! Game Over!');
    _handleGameOver();
  }

  // ✅ CORRECTION: Méthode Game Over complète
  void _handleGameOver() {
    if (!isGameRunning) return;

    print('💀 GAME OVER - Affichage overlay');
    isGameRunning = false;

    // Arrêter la musique
    AudioManager().stopMusic();

    // Afficher l'overlay game over
    overlays.add('gameOverOverlay');

    // Pause le jeu
    pauseEngine();

    print('🎮 Jeu en pause, overlay Game Over affiché');
  }

  void resetGame() {
    print('🔄 Réinitialisation du jeu...');

    // Réinitialiser l'état du jeu
    _score = 0;
    _gameTimer = 180;
    isGameRunning = true;
    _timeAccumulator = 0.0;

    // Réinitialiser le joueur
    player.position = Vector2(size.x / 4, size.y - 150);
    player.setMovementDirection(0.0);
    player.resetHealth(); // ✅ IMPORTANT: Reset la santé du joueur

    // Réinitialiser les ennemis
    enemyManager.clearAllEnemies();
    enemyManager.spawnEnemiesForStage(1, size);

    // Réinitialiser le parallax
    parallaxBackground.updateParallax(GameJoystickDirection.idle);

    // Réinitialiser les overlays
    overlays
      ..clear()
      ..add('hudOverlay');

    // Reprendre le moteur et la musique
    resumeEngine();
    AudioManager().playMusic('stage1_music.mp3');

    // Notifier l'UI
    onTimeUpdate?.call();
    onScoreUpdate?.call();

    print('✅ Jeu RÉINITIALISÉ - Timer: $_gameTimer secondes, Score: $_score');
  }

  // Méthodes utilitaires
  void addScore(int points) {
    _score += points;
    print('🎯 Score augmenté: $_score (+$points)');
    onScoreUpdate?.call();
  }

  void pauseGame() {
    if (!isGameRunning) return;

    isGameRunning = false;
    overlays.add('pauseOverlay');
    pauseEngine();
    AudioManager().pauseMusic();
    print('⏸️ Jeu mis en PAUSE');
  }

  void resumeGame() {
    if (isGameRunning) return;

    isGameRunning = true;
    overlays.remove('pauseOverlay');
    resumeEngine();
    AudioManager().resumeMusic();
    print('▶️ Jeu REPRIS');
  }

  void addTime(int seconds) {
    _gameTimer += seconds;
    onTimeUpdate?.call();
    print('⏱️ +$seconds secondes ajoutées - Timer: $_gameTimer');
  }

  void reduceTime(int seconds) {
    _gameTimer = (_gameTimer - seconds).clamp(0, 999);
    onTimeUpdate?.call();
    print('⏱️ -$seconds secondes - Timer: $_gameTimer');
  }

  void completeLevel() {
    isGameRunning = false;
    print('🎉 Niveau complété! Score final: $_score');

    // Ajouter un bonus de score pour la complétion rapide
    final timeBonus = _gameTimer * 10;
    addScore(timeBonus);

    // Afficher l'overlay de victoire
    overlays.add('victoryOverlay');
  }

  @override
  void onMount() {
    super.onMount();
    print('🎮 Jeu monté et prêt!');
  }

  @override
  void onRemove() {
    print('🗑️ Jeu démonté');
    AudioManager().stopMusic();
    super.onRemove();
  }

  // Getters
  int get currentScore => _score;
  int get gameTimer => _gameTimer;
  bool get gameRunning => isGameRunning;
  Player get playerRef => player;
  EnemyManager get enemyManagerRef => enemyManager;
}