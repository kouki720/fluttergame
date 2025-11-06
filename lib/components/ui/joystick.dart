import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

// RENOMMER l'enum pour éviter le conflit
enum GameJoystickDirection { idle, left, right, jump }

class JoystickComponent extends Component with TapCallbacks, HasGameRef {
  late Rect _leftZone;
  late Rect _rightZone;
  late Rect _jumpZone;

  GameJoystickDirection _currentDirection = GameJoystickDirection.idle; // CHANGER ICI
  bool _isJumping = false;

  // Callbacks pour communiquer avec le jeu
  final Function(GameJoystickDirection) onDirectionChanged; // CHANGER ICI
  final Function() onJump;

  JoystickComponent({
    required this.onDirectionChanged,
    required this.onJump,
  });

  @override
  void onLoad() {
    super.onLoad();
    _setupTouchZones();
  }

  void _setupTouchZones() {
    final screenSize = gameRef.size;

    // Zone gauche (40% de l'écran) - Déplacement
    _leftZone = Rect.fromLTWH(
        0,
        screenSize.y * 0.6,
        screenSize.x * 0.4,
        screenSize.y * 0.4
    );

    // Zone droite (40% de l'écran) - Déplacement
    _rightZone = Rect.fromLTWH(
        screenSize.x * 0.6,
        screenSize.y * 0.6,
        screenSize.x * 0.4,
        screenSize.y * 0.4
    );

    // Zone saut (20% du milieu en haut) - Saut
    _jumpZone = Rect.fromLTWH(
        screenSize.x * 0.4,
        screenSize.y * 0.1,
        screenSize.x * 0.2,
        screenSize.y * 0.2
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final position = event.localPosition;
    _handleTap(position);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _resetDirection();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _resetDirection();
  }

  void _handleTap(Vector2 position) {
    if (_jumpZone.contains(position.toOffset())) {
      _triggerJump();
    } else if (_leftZone.contains(position.toOffset())) {
      _setDirection(GameJoystickDirection.left); // CHANGER ICI
    } else if (_rightZone.contains(position.toOffset())) {
      _setDirection(GameJoystickDirection.right); // CHANGER ICI
    }
  }

  void _triggerJump() {
    if (!_isJumping) {
      _isJumping = true;
      onJump();

      Future.delayed(Duration(milliseconds: 500), () {
        _isJumping = false;
      });
    }
  }

  void _setDirection(GameJoystickDirection direction) { // CHANGER ICI
    if (_currentDirection != direction) {
      _currentDirection = direction;
      onDirectionChanged(direction);
    }
  }

  void _resetDirection() {
    if (_currentDirection != GameJoystickDirection.idle) { // CHANGER ICI
      _currentDirection = GameJoystickDirection.idle; // CHANGER ICI
      onDirectionChanged(GameJoystickDirection.idle); // CHANGER ICI
    }
  }

  @override
  void render(Canvas canvas) {
    // Pour debug (optionnel)
  }
}