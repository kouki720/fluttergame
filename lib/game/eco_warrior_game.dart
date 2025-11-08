// game/eco_warrior_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'parallax_background.dart';
import '../components/ui/joystick.dart';
import '../components/player/player.dart';
import '../managers/audio_manager.dart';

class EcoWarriorGame extends FlameGame with HasCollisionDetection {
  // Composants du jeu
  late final ParallaxBackground parallaxBackground;
  late final GameJoystickComponent joystick;
  late final Player player;

  // État du jeu
  int _score = 0;
  int _gameTimer = 180; // ✅ CORRECTION: Renommé pour éviter le conflit
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

    // Charger les composants en parallèle
    await Future.wait([
      _loadParallaxBackground(),
      _loadPlayer(),
      _loadJoystick(),
    ]);

    // Activer le HUD
    overlays.add('hudOverlay');

    print('✅ Jeu initialisé avec ${children.length} composants');
    print('📏 Taille de l\'écran: $size');
  }

  Future<void> _loadParallaxBackground() async {
    parallaxBackground = ParallaxBackground();
    await add(parallaxBackground);
    print('🌄 Background parallax chargé');
  }

  Future<void> _loadPlayer() async {
    player = Player(
      position: Vector2(size.x / 4, size.y - 150), // Position de départ
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

  void _handleDirectionChange(GameJoystickDirection direction) {
    if (!isGameRunning) return;

    switch (direction) {
      case GameJoystickDirection.left:
        player.setMovementDirection(-1.0);
        parallaxBackground.updateParallax(direction);
        print('⬅️ Déplacement vers la GAUCHE activé');
        break;
      case GameJoystickDirection.right:
        player.setMovementDirection(1.0);
        parallaxBackground.updateParallax(direction);
        print('➡️ Déplacement vers la DROITE activé');
        break;
      case GameJoystickDirection.idle:
        player.setMovementDirection(0.0);
        parallaxBackground.updateParallax(direction);
        print('⏹️ Déplacement arrêté - IDLE');
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

  void addScore(int points) {
    _score += points;
    print('🎯 Score augmenté: $_score (+$points)');
    onScoreUpdate?.call();
    onTimeUpdate?.call();
  }

  void pauseGame() {
    if (!isGameRunning) return;

    isGameRunning = false;
    overlays.add('pauseOverlay');
    pauseEngine();
    print('⏸️ Jeu mis en PAUSE');
  }

  void resumeGame() {
    if (isGameRunning) return;

    isGameRunning = true;
    overlays.remove('pauseOverlay');
    resumeEngine();
    print('▶️ Jeu REPRIS');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Mise à jour du timer
    if (isGameRunning && _gameTimer > 0) {
      _timeAccumulator += dt;
      if (_timeAccumulator >= 1.0) {
        _timeAccumulator = 0.0;
        _gameTimer--;
        onTimeUpdate?.call();

        print('⏰ Timer: ${_gameTimer ~/ 60}:${(_gameTimer % 60).toString().padLeft(2, '0')}');

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
    if (player.position.x < 0) {
      player.position.x = 0;
    } else if (player.position.x > size.x - player.size.x) {
      player.position.x = size.x - player.size.x;
    }
  }

  void _handleTimeOut() {
    print('⏰ TEMPS ÉCOULÉ! Game Over!');
    isGameRunning = false;
    onGameOver?.call();
    overlays.add('gameOverOverlay');
  }

  void resetGame() {
    // Réinitialiser l'état du jeu
    _score = 0;
    _gameTimer = 180;
    isGameRunning = true;
    _timeAccumulator = 0.0;

    // Réinitialiser le joueur
    player.position = Vector2(size.x / 4, size.y - 100);
    player.setMovementDirection(0.0);
    player.current = PlayerState.idle;

    // Réinitialiser le parallax
    parallaxBackground.updateParallax(GameJoystickDirection.idle);

    // Réinitialiser les overlays
    overlays
      ..clear()
      ..add('hudOverlay');

    // Reprendre le moteur
    resumeEngine();

    // Notifier l'UI
    onTimeUpdate?.call();

    print('🔄 Jeu RÉINITIALISÉ - Timer: $_gameTimer secondes');
  }

  // Méthodes utilitaires
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

  // Gestion des collisions (à implémenter plus tard)
  void _checkCollisions() {
    // À implémenter avec les ennemis et collectibles
  }

  @override
  void onMount() {
    super.onMount();
    print('🎮 Jeu monté et prêt!');
  }

  @override
  void onRemove() {
    print('🗑️ Jeu démonté');
    super.onRemove();
  }

  // ✅ CORRECTION: Getters renommés pour éviter les conflits
  int get currentScore => _score;
  int get gameTimer => _gameTimer; // ✅ Renommé pour éviter le conflit
  bool get gameRunning => isGameRunning;
  Player get playerRef => player; // Getter pour accéder au joueur
}