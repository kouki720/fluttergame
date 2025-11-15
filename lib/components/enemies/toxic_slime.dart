// components/enemies/toxic_slime.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';

class ToxicSlime extends Enemy {

  ToxicSlime({required Vector2 position})
      : super(
    position: position,
    size: Vector2(144, 144),
  ) {
    health = 60.0;
    maxHealth = 60.0;
    damage = 10.0;
    moveSpeed = 60.0;
    attackRange = 70.0;
    detectionRange = 200.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  Future<void> loadAnimations() async {
    try {
      // ✅ CORRECTION: Charger TOUTES les animations séparément
      final idleImage = await gameRef.images.load('enemies/toxic_slime/idle.png');
      final moveImage = await gameRef.images.load('enemies/toxic_slime/move.png');
      final attackImage = await gameRef.images.load('enemies/toxic_slime/attack.png');
      final hurtImage = await gameRef.images.load('enemies/toxic_slime/hurt.png');
      final dieImage = await gameRef.images.load('enemies/toxic_slime/die.png');

      // Animation Idle
      idleAnimation = SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.4,
        ),
      );

      // Animation Déplacement
      moveAnimation = SpriteAnimation.fromFrameData(
        moveImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.3,
        ),
      );

      // Animation Attaque
      attackAnimation = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.2,
        ),
      );

      // Animation Blessé
      hurtAnimation = SpriteAnimation.fromFrameData(
        hurtImage,
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2(90, 64),
          stepTime: 0.1,
        ),
      );

      // Animation Mort
      dyingAnimation = SpriteAnimation.fromFrameData(
        dieImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.25,
        ),
      );

      print('✅ Toutes les animations ToxicSlime chargées');

    } catch (e) {
      print('❌ Erreur chargement animations ToxicSlime: $e');
      await _createFallbackAnimations();
    }
  }

  Future<void> _createFallbackAnimations() async {
    try {
      final spriteSheet = await gameRef.images.load('player/idle.png');
      final fallbackSprite = Sprite(spriteSheet);

      // Fallback: utiliser la même animation pour tout
      idleAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      moveAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      attackAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      hurtAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      dyingAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);

      print('🔄 Fallback animations créées pour ToxicSlime');
    } catch (e) {
      print('❌ Erreur création fallback animations: $e');
    }
  }
}