// components/ui/joystick.dart
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:eco_warrior_tunisia1/managers/audio_manager.dart';

enum GameJoystickDirection { idle, left, right, jump }
enum GameAction { swordAttack, flameAttack }

class JoystickComponent extends PositionComponent with TapCallbacks, HasGameRef {
  final Function(GameJoystickDirection) onDirectionChanged;
  final Function() onJump;
  final Function(GameAction) onAction;

  // Dimensions des boutons
  double buttonSize = 0.0;
  double margin = 0.0;

  JoystickComponent({
    required this.onDirectionChanged,
    required this.onJump,
    required this.onAction,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Définir la taille et position du composant pour couvrir tout l'écran
    size = gameRef.size;
    position = Vector2.zero();

    // Calculer les dimensions des boutons
    buttonSize = size.x * 0.08;
    margin = size.x * 0.04;

    print('🎮 JoystickComponent chargé - Taille: $size');
    print('🎮 Bouton size: $buttonSize, Margin: $margin');
  }

  @override
  void render(Canvas canvas) {
    _renderMovementButtons(canvas);
    _renderActionButtons(canvas);
  }

  void _renderMovementButtons(Canvas canvas) {
    // Bouton gauche
    final leftButton = Rect.fromLTWH(
      margin,
      size.y - buttonSize - margin,
      buttonSize,
      buttonSize,
    );

    // Bouton droite
    final rightButton = Rect.fromLTWH(
      margin + buttonSize + 8,
      size.y - buttonSize - margin,
      buttonSize,
      buttonSize,
    );

    _drawButton(canvas, leftButton, Icons.arrow_back_ios, Colors.white.withOpacity(0.3));
    _drawButton(canvas, rightButton, Icons.arrow_forward_ios, Colors.white.withOpacity(0.3));
  }

  void _renderActionButtons(Canvas canvas) {
    final buttonSpacing = 8.0;

    final jumpButton = Rect.fromLTWH(
      size.x - (buttonSize * 2) - margin - buttonSpacing,
      size.y - buttonSize - margin,
      buttonSize,
      buttonSize,
    );

    final swordButton = Rect.fromLTWH(
      size.x - buttonSize - margin,
      size.y - buttonSize - margin,
      buttonSize,
      buttonSize,
    );

    final flameButton = Rect.fromLTWH(
      size.x - buttonSize - margin,
      size.y - (buttonSize * 2) - margin - buttonSpacing,
      buttonSize,
      buttonSize,
    );

    _drawButton(canvas, jumpButton, Icons.arrow_upward, Colors.green.withOpacity(0.3));
    _drawButton(canvas, swordButton, Icons.architecture, Colors.blue.withOpacity(0.3));
    _drawButton(canvas, flameButton, Icons.local_fire_department, Colors.orange.withOpacity(0.3));
  }

  void _drawButton(Canvas canvas, Rect rect, IconData icon, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(rect.center, rect.width / 2, paint);
    canvas.drawCircle(rect.center, rect.width / 2, borderPaint);

    // Icône
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: rect.width / 2.5,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    final position = event.localPosition;
    print('🖱️ TapDown détecté à la position: $position');
    _handleTap(position);
  }

  @override
  void onTapUp(TapUpEvent event) {
    print('🖱️ TapUp - Retour à l\'état idle');
    onDirectionChanged(GameJoystickDirection.idle);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    print('🖱️ TapCancel - Retour à l\'état idle');
    onDirectionChanged(GameJoystickDirection.idle);
  }

  void _handleTap(Vector2 position) {
    final buttonSpacing = 8.0;

    // Boutons mouvement
    final leftButton = Rect.fromLTWH(
        margin,
        size.y - buttonSize - margin,
        buttonSize,
        buttonSize
    );

    final rightButton = Rect.fromLTWH(
        margin + buttonSize + 8,
        size.y - buttonSize - margin,
        buttonSize,
        buttonSize
    );

    // Boutons action
    final jumpButton = Rect.fromLTWH(
      size.x - (buttonSize * 2) - margin - buttonSpacing,
      size.y - buttonSize - margin,
      buttonSize,
      buttonSize,
    );

    final swordButton = Rect.fromLTWH(
      size.x - buttonSize - margin,
      size.y - buttonSize - margin,
      buttonSize,
      buttonSize,
    );

    final flameButton = Rect.fromLTWH(
      size.x - buttonSize - margin,
      size.y - (buttonSize * 2) - margin - buttonSpacing,
      buttonSize,
      buttonSize,
    );

    print('🎯 Vérification des boutons:');
    print('   Left: $leftButton');
    print('   Right: $rightButton');
    print('   Jump: $jumpButton');
    print('   Sword: $swordButton');
    print('   Flame: $flameButton');
    print('   Position tap: $position');

    // Détection des boutons avec sons et messages de console
    if (leftButton.contains(Offset(position.x, position.y))) {
      print('⬅️ BOUTON GAUCHE pressé!');
      AudioManager().playSfx('button_click.mp3');
      onDirectionChanged(GameJoystickDirection.left);
    } else if (rightButton.contains(Offset(position.x, position.y))) {
      print('➡️ BOUTON DROITE pressé!');
      AudioManager().playSfx('button_click.mp3');
      onDirectionChanged(GameJoystickDirection.right);
    } else if (jumpButton.contains(Offset(position.x, position.y))) {
      print('🦘 BOUTON JUMP pressé!');
      AudioManager().playSfx('button_click.mp3');
      onJump();
    } else if (swordButton.contains(Offset(position.x, position.y))) {
      print('⚔️ BOUTON SWORD pressé!');
      AudioManager().playSfx('button_click.mp3');
      onAction(GameAction.swordAttack);
    } else if (flameButton.contains(Offset(position.x, position.y))) {
      print('🔥 BOUTON FLAME pressé!');
      AudioManager().playSfx('button_click.mp3');
      onAction(GameAction.flameAttack);
    } else {
      print('🎯 Tap en dehors des boutons - Position: $position');
    }
  }
}