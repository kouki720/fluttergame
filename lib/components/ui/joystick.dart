// components/ui/joystick.dart
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:eco_warrior_tunisia1/managers/audio_manager.dart';

enum GameJoystickDirection { idle, left, right, jump }
enum GameAction { swordAttack, flameAttack }

class GameJoystickComponent extends PositionComponent with TapCallbacks, HasGameRef {
  final Function(GameJoystickDirection) onDirectionChanged;
  final Function() onJump;
  final Function(GameAction) onAction;

  // Variables pour les boutons
  late final CircleComponent _leftButton;
  late final CircleComponent _rightButton;
  late final CircleComponent _jumpButton;
  late final CircleComponent _swordButton;
  late final CircleComponent _flameButton;

  GameJoystickComponent({
    required this.onDirectionChanged,
    required this.onJump,
    required this.onAction,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ✅ CORRECTION : Utiliser game.size au lieu de gameRef.size
    size = game.size;
    position = Vector2.zero();

    final buttonSize = size.x * 0.08;
    final margin = size.x * 0.04;
    final buttonSpacing = 8.0;

    // Créer les boutons avec les nouveaux composants CircleComponent
    _leftButton = CircleComponent(
      radius: buttonSize / 2,
      position: Vector2(margin + buttonSize / 2, size.y - margin - buttonSize / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white.withOpacity(0.3),
    );

    _rightButton = CircleComponent(
      radius: buttonSize / 2,
      position: Vector2(margin + buttonSize * 1.5 + 8, size.y - margin - buttonSize / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white.withOpacity(0.3),
    );

    _jumpButton = CircleComponent(
      radius: buttonSize / 2,
      position: Vector2(
        size.x - (buttonSize * 1.5) - margin - buttonSpacing,
        size.y - margin - buttonSize / 2,
      ),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.green.withOpacity(0.3),
    );

    _swordButton = CircleComponent(
      radius: buttonSize / 2,
      position: Vector2(size.x - margin - buttonSize / 2, size.y - margin - buttonSize / 2),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.blue.withOpacity(0.3),
    );

    _flameButton = CircleComponent(
      radius: buttonSize / 2,
      position: Vector2(
        size.x - margin - buttonSize / 2,
        size.y - margin - buttonSize * 1.5 - buttonSpacing,
      ),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.orange.withOpacity(0.3),
    );

    // Ajouter tous les boutons comme enfants
    await addAll([_leftButton, _rightButton, _jumpButton, _swordButton, _flameButton]);

    print('🎮 GameJoystickComponent initialisé avec ${children.length} boutons');
    print('📏 Taille des boutons: $buttonSize, Écran: $size');
  }

  @override
  void onTapDown(TapDownEvent event) {
    final position = event.localPosition;
    print('🖱️ Tap détecté à: $position');
    _handleTap(position);
  }

  void _handleTap(Vector2 position) {
    // Vérifier chaque bouton avec containsPoint
    if (_leftButton.containsPoint(position)) {
      _triggerButton('GAUCHE', () => onDirectionChanged(GameJoystickDirection.left));
    } else if (_rightButton.containsPoint(position)) {
      _triggerButton('DROITE', () => onDirectionChanged(GameJoystickDirection.right));
    } else if (_jumpButton.containsPoint(position)) {
      _triggerButton('JUMP', onJump);
    } else if (_swordButton.containsPoint(position)) {
      _triggerButton('SWORD', () => onAction(GameAction.swordAttack));
    } else if (_flameButton.containsPoint(position)) {
      _triggerButton('FLAME', () => onAction(GameAction.flameAttack));
    } else {
      print('🎯 Tap en dehors des boutons');
    }
  }

  void _triggerButton(String buttonName, VoidCallback action) {
    print('🎯 BOUTON $buttonName pressé!');
    AudioManager().playSfx('button_click.mp3');

    // Effet visuel temporaire
    _animateButtonPress(buttonName);

    // Exécuter l'action
    action();
  }

  void _animateButtonPress(String buttonName) {
    final button = _getButtonByName(buttonName);
    if (button != null) {
      final originalColor = button.paint.color;
      button.paint.color = originalColor.withOpacity(0.6);

      // Timer pour remettre la couleur originale
      final timer = TimerComponent(
        period: 0.1,
        removeOnFinish: true,
        onTick: () {
          button.paint.color = originalColor;
        },
      );
      add(timer);
    }
  }

  CircleComponent? _getButtonByName(String name) {
    switch (name) {
      case 'GAUCHE': return _leftButton;
      case 'DROITE': return _rightButton;
      case 'JUMP': return _jumpButton;
      case 'SWORD': return _swordButton;
      case 'FLAME': return _flameButton;
      default: return null;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    print('🖱️ Tap relâché - Retour à idle');
    onDirectionChanged(GameJoystickDirection.idle);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    print('🖱️ Tap annulé - Retour à idle');
    onDirectionChanged(GameJoystickDirection.idle);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Le texte de débogage a été supprimé - plus d'écriture blanche
  }
}