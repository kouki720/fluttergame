// components/enemies/toxic_slime.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
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
  Future<void> loadAnimations() async {
    try {
      final idleImage = await gameRef.images.load('enemies/toxic_slime/idle.png');
      idleAnimation = SpriteAnimation.fromFrameData(
        idleImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.4,
        ),
      );

      final moveImage = await gameRef.images.load('enemies/toxic_slime/move.png');
      moveAnimation = SpriteAnimation.fromFrameData(
        moveImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.3,
        ),
      );

      final attackImage = await gameRef.images.load('enemies/toxic_slime/attack.png');
      attackAnimation = SpriteAnimation.fromFrameData(
        attackImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.2,
        ),
      );

      setAttackAnimationDuration(0.2 * 3);

      final hurtImage = await gameRef.images.load('enemies/toxic_slime/hurt.png');
      hurtAnimation = SpriteAnimation.fromFrameData(
        hurtImage,
        SpriteAnimationData.sequenced(
          amount: 2,
          textureSize: Vector2(90, 64),
          stepTime: 0.1,
        ),
      );

      final dieImage = await gameRef.images.load('enemies/toxic_slime/die.png');
      dyingAnimation = SpriteAnimation.fromFrameData(
        dieImage,
        SpriteAnimationData.sequenced(
          amount: 3,
          textureSize: Vector2(90, 64),
          stepTime: 0.25,
        ),
      );

      print('✅ ToxicSlime animations chargées');

    } catch (e) {
      print('❌ Erreur animations ToxicSlime: $e');
      await _createFallbackAnimations();
    }
  }

  Future<void> _createFallbackAnimations() async {
    try {
      final spriteSheet = await gameRef.images.load('player/idle.png');
      final fallbackSprite = Sprite(spriteSheet);

      idleAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      moveAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      attackAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      hurtAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);
      dyingAnimation = SpriteAnimation.spriteList([fallbackSprite], stepTime: 0.4);

      setAttackAnimationDuration(0.6);
    } catch (e) {
      print('❌ Erreur fallback: $e');
    }
  }
}