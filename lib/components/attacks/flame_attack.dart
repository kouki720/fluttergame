// components/attacks/flame_attack.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class FlameAttack extends SpriteAnimationComponent with HasGameRef {
  final int direction; // 1 pour droite, -1 pour gauche
  final double speed = 400.0;
  final double lifeTime = 2.0;

  late final SpriteAnimation _animation;
  TimerComponent? _lifeTimer;

  FlameAttack({
    required Vector2 position,
    required this.direction,
  }) : super(
      position: position,
      size: Vector2(256, 128) // ✅ Taille augmentée 4 fois (64*4=256, 32*4=128)
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    anchor = Anchor.center;

    // Charger l'animation de flamme
    await _loadFlameAnimation();

    if (_animation.frames.isNotEmpty) {
      animation = _animation;
    } else {
      print('❌ Erreur: Animation flamme non chargée');
      removeFromParent();
      return;
    }

    // Appliquer la direction
    if (direction < 0) {
      flipHorizontallyAroundCenter();
    }

    // Timer de durée de vie
    _lifeTimer = TimerComponent(
      period: lifeTime,
      removeOnFinish: true,
      onTick: () {
        removeFromParent();
      },
    );
    add(_lifeTimer!);

    print('🔥 Flamme créée! Direction: $direction, Position: $position, Taille: $size');
  }

  Future<void> _loadFlameAnimation() async {
    try {
      // ✅ CORRECTION: Taille des sprites augmentée pour correspondre à la nouvelle taille
      final frames = <Sprite>[];

      for (int i = 1; i <= 6; i++) {
        final frameImage = await gameRef.images.load('attacks/flame/flame$i.png');
        final sprite = Sprite(frameImage);
        frames.add(sprite);
      }

      _animation = SpriteAnimation.spriteList(
        frames,
        stepTime: 0.1,
        loop: true,
      );

      print('✅ Animation flamme chargée avec ${frames.length} frames - Taille: $size');

    } catch (e) {
      print('❌ Erreur chargement animation flamme: $e');

      // Fallback: essayer l'ancienne méthode
      try {
        final flameImage = await gameRef.images.load('attacks/flame/flamerouge.png');
        _animation = SpriteAnimation.fromFrameData(
          flameImage,
          SpriteAnimationData.sequenced(
            amount: 4,
            textureSize: Vector2(96, 48), // ✅ Taille augmentée pour le fallback aussi
            stepTime: 0.1,
          ),
        );
        print('✅ Fallback: Animation spritesheet chargée avec taille augmentée');
      } catch (e2) {
        print('❌ Fallback échoué: $e2');
        _animation = SpriteAnimation.spriteList([], stepTime: 0.1);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Déplacement de la flamme
    position.x += direction * speed * dt;

    // Vérification des bords
    if (position.x < -size.x || position.x > gameRef.size.x + size.x) {
      removeFromParent();
      print('🔥 Flamme supprimée (hors écran)');
    }
  }

  @override
  void onRemove() {
    _lifeTimer?.removeFromParent();
    print('🔥 Flamme détruite');
    super.onRemove();
  }
}