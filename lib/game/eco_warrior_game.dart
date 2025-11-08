// game/eco_warrior_game.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'parallax_background.dart';
import '../components/ui/joystick.dart';
import '../managers/audio_manager.dart';

class EcoWarriorGame extends FlameGame {
  late final JoystickComponent joystick;
  late final ParallaxBackground parallaxBackground;

  double playerVelocityX = 0.0;
  bool isJumping = false;
  int score = 0;
  int timer = 180;
  bool isGameRunning = true;
  double _timeAccumulator = 0.0;

  // Callbacks pour l'UI
  VoidCallback? onTimeUpdate;
  VoidCallback? onGameOver;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    print('🎮 Initialisation du jeu EcoWarrior...');

    // Initialiser le background en premier
    parallaxBackground = ParallaxBackground();
    await add(parallaxBackground);

    // Initialiser le joystick
    joystick = JoystickComponent(
      onDirectionChanged: _handleDirectionChange,
      onJump: _handleJump,
      onAction: _handleAction,
    );
    await add(joystick);

    print('✅ Jeu initialisé avec succès - Joystick prêt');
    print('📏 Taille de l\'écran du jeu: $size');

    // Ajouter le HUD
    overlays.add('hudOverlay');
  }

  void _handleDirectionChange(GameJoystickDirection direction) {
    if (!isGameRunning) {
      print('⏸️ Jeu en pause - Ignorer l\'input');
      return;
    }

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
      // Géré séparément
        break;
    }
  }

  void _handleJump() {
    if (!isGameRunning) {
      print('⏸️ Jeu en pause - Ignorer le saut');
      return;
    }

    if (!isJumping) {
      isJumping = true;
      print('🦘 SAUT effectué!');

      // Jouer le son de saut
      AudioManager().playJumpSfx();

      Future.delayed(const Duration(milliseconds: 800), () {
        isJumping = false;
        print('🦘 Saut terminé - Prêt pour un nouveau saut');
      });
    } else {
      print('🦘 Déjà en train de sauter - Attendre la fin');
    }
  }

  void _handleAction(GameAction action) {
    if (!isGameRunning) {
      print('⏸️ Jeu en pause - Ignorer l\'action');
      return;
    }

    switch (action) {
      case GameAction.swordAttack:
        print('⚔️ ATTAQUE ÉPÉE déclenchée!');
        AudioManager().playSwordAttackSfx();
        break;
      case GameAction.flameAttack:
        print('🔥 ATTAQUE FLAMME déclenchée!');
        AudioManager().playFlameAttackSfx();
        break;
    }
  }

  void addScore(int points) {
    score += points;
    print('🎯 Score augmenté: $score (+$points)');

    // Notifier l'UI
    onTimeUpdate?.call();
  }

  void pauseGame() {
    if (!isGameRunning) return;

    isGameRunning = false;
    overlays.add('pauseOverlay');
    print('⏸️ Jeu mis en PAUSE');
  }

  void resumeGame() {
    if (isGameRunning) return;

    isGameRunning = true;
    overlays.remove('pauseOverlay');
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

        // Notifier l'UI du changement de temps
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

    // Notifier l'UI
    onGameOver?.call();

    // Afficher l'overlay Game Over
    overlays.add('gameOverOverlay');
  }

  void resetGame() {
    score = 0;
    timer = 180;
    playerVelocityX = 0.0;
    isJumping = false;
    isGameRunning = true;
    _timeAccumulator = 0.0;

    // Réinitialiser le parallax
    parallaxBackground.updateParallax(GameJoystickDirection.idle);

    // Réinitialiser les overlays
    overlays.clear();
    overlays.add('hudOverlay');

    print('🔄 Jeu RÉINITIALISÉ - Timer: $timer secondes');

    // Notifier l'UI
    onTimeUpdate?.call();
  }
}