// components/enemies/plastic_monster.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';

class PlasticMonster extends Enemy {

  PlasticMonster({required Vector2 position})
      : super(
    position: position,
    size: Vector2(192, 192),
  ) {
    health = 80.0;
    maxHealth = 80.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    print('🔍 PlasticMonster - Position: $position, Size: $size, Anchor: $anchor');
  }

  @override
  Future<void> loadAnimations() async {
    try {
      final idleImage = await gameRef.images.load('enemies/plastic_monster/idle.png');

      // ✅ SEULEMENT idleAnimation
      idleAnimation = SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: 5,
          textureSize: Vector2(70, 70),
          stepTime: 0.3,
        ),
      );

      print('✅ Animation PlasticMonster chargée - 4 frames, stepTime: 0.3s');

    } catch (e) {
      print('❌ Erreur chargement animation PlasticMonster: $e');
      await _createFallbackAnimation();
    }
  }

  Future<void> _createFallbackAnimation() async {
    try {
      final spriteSheet = await gameRef.images.load('player/idle.png');
      final fallbackSprite = Sprite(spriteSheet);

      // ✅ SEULEMENT idleAnimation
      idleAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.3);

      print('🔄 Fallback animation créée pour PlasticMonster');
    } catch (e) {
      print('❌ Erreur création fallback animation: $e');
      _createBasicAnimation();
    }
  }

  void _createBasicAnimation() {
    try {
      gameRef.images.load('player/idle.png').then((image) {
        final sprite = Sprite(image);

        // ✅ SEULEMENT idleAnimation
        idleAnimation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);

        print('🆘 Animation basique créée pour PlasticMonster');
      });
    } catch (e) {
      print('💀 Erreur création animation basique: $e');
      _createEmptyAnimation();
    }
  }

  void _createEmptyAnimation() {
    try {
      Future.delayed(Duration(milliseconds: 500), () async {
        try {
          final image = await gameRef.images.load('player/idle.png');
          final sprite = Sprite(image);

          // ✅ SEULEMENT idleAnimation
          idleAnimation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);
        } catch (e) {
          print('⚠️ Impossible de créer l\'animation même après délai');
        }
      });

      gameRef.images.load('player/idle.png').then((tempImage) {
        final tempSprite = Sprite(tempImage);

        // ✅ SEULEMENT idleAnimation
        idleAnimation = SpriteAnimation.spriteList([tempSprite], stepTime: 1.0);

        print('⚪ Animation temporaire créée pour PlasticMonster');
      }).catchError((e) {
        print('💥 Erreur lors du chargement de l\'image temporaire: $e');
        _createUltimateFallback();
      });

    } catch (e) {
      print('💥 ERREUR CRITIQUE dans _createEmptyAnimation: $e');
      _createUltimateFallback();
    }
  }

  void _createUltimateFallback() {
    try {
      gameRef.images.load('player/idle.png').then((image) {
        final sprite = Sprite(image);

        // ✅ SEULEMENT idleAnimation
        idleAnimation = SpriteAnimation.spriteList([sprite], stepTime: 1.0);

        print('🆘 Fallback ultime utilisé pour PlasticMonster');
      });
    } catch (e) {
      print('💀 Impossible de créer aucune animation');
    }
  }
}