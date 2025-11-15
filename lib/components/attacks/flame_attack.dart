// components/attacks/flame_attack.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../enemies/enemy.dart';
import '../../game/eco_warrior_game.dart';

class FlameAttack extends SpriteAnimationComponent
    with HasGameRef<EcoWarriorGame> {
  final int direction; // 1 pour droite, -1 pour gauche
  final double speed = 400.0;
  final double lifeTime = 2.0;
  final double damage = 25.0; // ✅ AJOUT: Dégâts de la flamme
  final double attackRange = 50.0; // ✅ AJOUT: Portée d'attaque

  late final SpriteAnimation _animation;
  TimerComponent? _lifeTimer;
  Set<Enemy> _hitEnemies = {}; // ✅ AJOUT: Éviter les dégâts multiples

  FlameAttack({
    required Vector2 position,
    required this.direction,
  }) : super(
      position: position,
      size: Vector2(256, 128)
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

    print('🔥 Flamme créée! Direction: $direction, Position: $position, Taille: $size, Dégâts: $damage');
  }

  Future<void> _loadFlameAnimation() async {
    try {
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

      print('✅ Animation flamme chargée avec ${frames.length} frames');

    } catch (e) {
      print('❌ Erreur chargement animation flamme: $e');

      // Fallback
      try {
        final flameImage = await gameRef.images.load('attacks/flame/flamerouge.png');
        _animation = SpriteAnimation.fromFrameData(
          flameImage,
          SpriteAnimationData.sequenced(
            amount: 4,
            textureSize: Vector2(96, 48),
            stepTime: 0.1,
          ),
        );
        print('✅ Fallback: Animation spritesheet chargée');
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

    // ✅ AJOUT: Vérifier les collisions avec les ennemis
    _checkEnemyCollisions();

    // Vérification des bords
    if (position.x < -size.x || position.x > gameRef.size.x + size.x) {
      removeFromParent();
      print('🔥 Flamme supprimée (hors écran)');
    }
  }

  // ✅ AJOUT: Méthode pour vérifier les collisions avec les ennemis
  void _checkEnemyCollisions() {
    for (final enemy in gameRef.enemyManager.activeEnemies) {
      // Vérifier si l'ennemi est déjà touché par cette flamme
      if (_hitEnemies.contains(enemy)) continue;

      // Vérifier la distance entre la flamme et l'ennemi
      final distance = (enemy.position - position).length;

      if (distance <= attackRange && enemy.isAlive) {
        // Infliger des dégâts à l'ennemi
        enemy.takeDamage(damage);
        _hitEnemies.add(enemy);

        print('🔥 Flamme touche ${enemy.runtimeType}! Dégâts: $damage, PV restants: ${enemy.health}');

        // Jouer un son d'impact
        // AudioManager().playSfx('flame_hit.mp3');
      }
    }
  }

  @override
  void onRemove() {
    _lifeTimer?.removeFromParent();
    _hitEnemies.clear();
    print('🔥 Flamme détruite');
    super.onRemove();
  }
}