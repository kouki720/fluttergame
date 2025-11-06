import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'parallax_background.dart';
import '../components/ui/joystick.dart';

class EcoWarriorGame extends FlameGame {
  late final JoystickComponent joystick;
  late final ParallaxBackground parallaxBackground;

  double playerVelocityX = 0.0;
  bool isJumping = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    parallaxBackground = ParallaxBackground();
    await add(parallaxBackground);

    joystick = JoystickComponent(
      onDirectionChanged: _handleDirectionChange,
      onJump: _handleJump,
    );
    await add(joystick);
  }

  void _handleDirectionChange(GameJoystickDirection direction) { // CHANGER ICI
    switch (direction) {
      case GameJoystickDirection.left: // CHANGER ICI
        playerVelocityX = -1.0;
        parallaxBackground.updateParallax(direction);
        break;
      case GameJoystickDirection.right: // CHANGER ICI
        playerVelocityX = 1.0;
        parallaxBackground.updateParallax(direction);
        break;
      case GameJoystickDirection.idle: // CHANGER ICI
        playerVelocityX = 0.0;
        parallaxBackground.updateParallax(direction);
        break;
      case GameJoystickDirection.jump: // CHANGER ICI
      // Le saut est géré séparément
        break;
    }

    print('Direction: $direction, VelocityX: $playerVelocityX');
  }

  void _handleJump() {
    if (!isJumping) {
      isJumping = true;
      print('JUMP!');

      Future.delayed(Duration(milliseconds: 800), () {
        isJumping = false;
      });
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }
}