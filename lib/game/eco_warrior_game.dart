// game/eco_warrior_game.dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'parallax_background.dart';
import '../components/ui/joystick.dart';
import '../managers/audio_manager.dart';

class EcoWarriorGame extends FlameGame with HasCollisionDetection {
  // Nouveaux composants avec Flame 1.33.0
  late final ParallaxBackground parallaxBackground;
  late final GameJoystickComponent joystick; // 🔥 CHANGEMENT : GameJoystickComponent

  // État du jeu
  double playerVelocityX = 0.0;
  bool isJumping = false;
  int score = 0;
  int timer = 180;
  bool isGameRunning = true;
  double _timeAccumulator = 0.0;

  // Nouveaux callbacks avec Flame 1.33.0
  VoidCallback? onTimeUpdate;
  VoidCallback? onGameOver;
  VoidCallback? onScoreUpdate;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    print('🎮 Initialisation du jeu EcoWarrior avec Flame 1.33.0...');

    // Charger les composants en parallèle (nouveauté Flame 1.33.0)
    await Future.wait([
      _loadParallaxBackground(),
      _loadJoystick(),
    ]);

    // Activer le HUD
    overlays.add('hudOverlay');

    print('✅ Jeu initialisé avec ${children.length} composants');
  }

  Future<void> _loadParallaxBackground() async {
    parallaxBackground = ParallaxBackground();
    await add(parallaxBackground);
  }

  Future<void> _loadJoystick() async {
    joystick = GameJoystickComponent( // 🔥 CHANGEMENT : GameJoystickComponent
      onDirectionChanged: _handleDirectionChange,
      onJump: _handleJump,
      onAction: _handleAction,
    );
    await add(joystick);
  }

  void _handleDirectionChange(GameJoystickDirection direction) {
    if (!isGameRunning) return;

    switch (direction) {
      case GameJoystickDirection.left:
        playerVelocityX = -1.0;
        parallaxBackground.updateParallax(direction);
        print('⬅️ Déplacement vers la GAUCHE activé');
        break;
      case GameJoystickDirection.right:
        playerVelocityX = 1.0;
        parallaxBackground.updateParallax(direction);
        print('➡️ Déplacement vers la DROITE activé');
        break;
      case GameJoystickDirection.idle:
        playerVelocityX = 0.0;
        parallaxBackground.updateParallax(direction);
        print('⏹️ Déplacement arrêté - IDLE');
        break;
      case GameJoystickDirection.jump:
        break;
    }
  }

  void _handleJump() {
    if (!isGameRunning || isJumping) return;

    isJumping = true;
    print('🦘 SAUT effectué!');
    AudioManager().playJumpSfx();

    // Nouvelle méthode avec TimerComponent
    add(TimerComponent(
      period: 0.8,
      removeOnFinish: true,
      onTick: () {
        isJumping = false;
        print('🦘 Saut terminé');
      },
    ));
  }

  void _handleAction(GameAction action) {
    if (!isGameRunning) return;

    switch (action) {
      case GameAction.swordAttack:
        print('⚔️ ATTAQUE ÉPÉE déclenchée!');
        AudioManager().playSwordAttackSfx();
        _spawnSwordEffect();
        break;
      case GameAction.flameAttack:
        print('🔥 ATTAQUE FLAMME déclenchée!');
        AudioManager().playFlameAttackSfx();
        _spawnFlameEffect();
        break;
    }
  }

  // Nouveaux effets visuels avec Flame 1.33.0
  void _spawnSwordEffect() {
    print('⚔️ Effet épée créé');
    // À implémenter avec des composants d'effets
  }

  void _spawnFlameEffect() {
    print('🔥 Effet flamme créé');
    // À implémenter avec des composants d'effets
  }

  void addScore(int points) {
    score += points;
    print('🎯 Score augmenté: $score (+$points)');
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

    if (isGameRunning && timer > 0) {
      _timeAccumulator += dt;
      if (_timeAccumulator >= 1.0) {
        _timeAccumulator = 0.0;
        timer--;
        onTimeUpdate?.call();

        print('⏰ Timer: ${timer ~/ 60}:${(timer % 60).toString().padLeft(2, '0')}');

        if (timer <= 0) {
          _handleTimeOut();
        }
      }
    }
  }

  void _handleTimeOut() {
    print('⏰ TEMPS ÉCOULÉ! Game Over!');
    isGameRunning = false;
    onGameOver?.call();
    overlays.add('gameOverOverlay');
  }

  void resetGame() {
    score = 0;
    timer = 180;
    playerVelocityX = 0.0;
    isJumping = false;
    isGameRunning = true;
    _timeAccumulator = 0.0;

    parallaxBackground.updateParallax(GameJoystickDirection.idle);

    // Nouvelle méthode pour reset les overlays
    overlays
      ..clear()
      ..add('hudOverlay');

    resumeEngine();
    onTimeUpdate?.call();

    print('🔄 Jeu RÉINITIALISÉ - Timer: $timer secondes');
  }

  // Nouvelle méthode pour les power-ups
  void addTime(int seconds) {
    timer += seconds;
    onTimeUpdate?.call();
    print('⏱️ +$seconds secondes ajoutées');
  }

  // Nouvelle méthode pour les collisions
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
}