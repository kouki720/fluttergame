// components/enemies/plastic_monster.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';

class PlasticMonster extends Enemy {

  PlasticMonster({required Vector2 position})
      : super(
    position: position,
    size: Vector2(180, 128),
  ) {
    health = 80.0;
    maxHealth = 80.0;
    damage = 15.0;
    moveSpeed = 40.0;
    attackRange = 80.0;
    detectionRange = 250.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  @override
  Future<void> loadAnimations() async {
    try {
      // ✅ CORRECTION: Charger TOUTES les animations séparément
      final idleImage = await gameRef.images.load('enemies/plastic_monster/idle.png');
      final moveImage = await gameRef.images.load('enemies/plastic_monster/move.png');
      final attackImage = await gameRef.images.load('enemies/plastic_monster/attack.png');
      final hurtImage = await gameRef.images.load('enemies/plastic_monster/hurt.png');
      final dieImage = await gameRef.images.load('enemies/plastic_monster/die.png');

      // Animation Idle
      idleAnimation = SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(90, 64),
          stepTime: 0.3,
        ),
      );

      // Animation Déplacement
      moveAnimation = SpriteAnimation.fromFrameData(
        moveImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(90, 64),
          stepTime: 0.2,
        ),
      );

      // Animation Attaque
      attackAnimation = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2(90, 64),
          stepTime: 0.15,
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
          amount: 4,
          textureSize: Vector2(90, 64),
          stepTime: 0.2,
        ),
      );

      print('✅ Toutes les animations PlasticMonster chargées');

    } catch (e) {
      print('❌ Erreur chargement animations PlasticMonster: $e');
      await _createFallbackAnimations();
    }
  }

  Future<void> _createFallbackAnimations() async {
    try {
      final spriteSheet = await gameRef.images.load('player/idle.png');
      final fallbackSprite = Sprite(spriteSheet);

      // Fallback: utiliser la même animation pour tout
      idleAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.3);
      moveAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.3);
      attackAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.3);
      hurtAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.3);
      dyingAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.3);

      print('🔄 Fallback animations créées pour PlasticMonster');
    } catch (e) {
      print('❌ Erreur création fallback animations: $e');
    }
  }
}