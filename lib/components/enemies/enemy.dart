// components/enemies/enemy.dart
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../../game/eco_warrior_game.dart';

enum EnemyState { idle, moving, attacking, hurt, dying }

abstract class Enemy extends SpriteAnimationGroupComponent<EnemyState>
    with HasGameRef<EcoWarriorGame> {

  // Propriétés de base
  double health = 100.0;
  double maxHealth = 100.0;
  double damage = 10.0;
  double moveSpeed = 50.0;
  double attackRange = 100.0;
  double detectionRange = 200.0;

  bool isActive = true;
  bool isFacingRight = false;
  bool isAttacking = false;

  // Référence au joueur
  Vector2? playerPosition;

  // Animations
  late SpriteAnimation idleAnimation;
  late SpriteAnimation moveAnimation;
  late SpriteAnimation attackAnimation;
  late SpriteAnimation hurtAnimation;
  late SpriteAnimation dyingAnimation;

  // Barre de santé
  late final HealthBar _healthBar;

  // Timer pour éviter les attaques continues
  TimerComponent? _attackTimer;
  bool _canAttack = true;

  // Durée d'animation d'attaque
  double _attackAnimationDuration = 0.6;

  Enemy({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size) {
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await loadAnimations();

    animations = {
      EnemyState.idle: idleAnimation,
      EnemyState.moving: moveAnimation,
      EnemyState.attacking: attackAnimation,
      EnemyState.hurt: hurtAnimation,
      EnemyState.dying: dyingAnimation,
    };

    current = EnemyState.idle;

    _healthBar = HealthBar(
      enemy: this,
      position: Vector2(0, -size.y - 5),
    );
    await add(_healthBar);

    print('✅ ${runtimeType} chargé à la position: $position');
  }

  Future<void> loadAnimations();

  void setAttackAnimationDuration(double duration) {
    _attackAnimationDuration = duration;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;

    if (isAttacking) return;

    _updateAI(dt);

    if (current != EnemyState.attacking && current != EnemyState.hurt && current != EnemyState.dying) {
      _updateFacingDirection();
    }
  }

  void _updateAI(double dt) {
    if (playerPosition == null) return;

    final distanceToPlayer = (playerPosition! - position).length;

    if (distanceToPlayer <= attackRange && _canAttack) {
      startAttack();
    } else if (distanceToPlayer <= detectionRange && !isAttacking) {
      current = EnemyState.moving;
      _moveTowardsPlayer(dt);
    } else if (!isAttacking) {
      current = EnemyState.idle;
    }
  }

  // MÉTHODE PUBLIQUE pour démarrer l'attaque
  void startAttack() {
    if (!_canAttack || isAttacking) return;

    isAttacking = true;
    _canAttack = false;
    current = EnemyState.attacking;

    print('⚔️ ${runtimeType} commence l\'attaque!');

    _attackTimer = TimerComponent(
      period: _attackAnimationDuration,
      removeOnFinish: true,
      onTick: () {
        _finishAttack();
      },
    );
    add(_attackTimer!);

    // Infliger des dégâts au milieu de l'animation
    Future.delayed(Duration(milliseconds: (_attackAnimationDuration * 500).toInt()), () {
      if (isActive && isAttacking && playerPosition != null) {
        final distance = (playerPosition! - position).length;
        if (distance <= attackRange) {
          gameRef.player.takeDamage(damage);
          print('💥 ${runtimeType} inflige $damage dégâts!');
        }
      }
    });
  }

  void _finishAttack() {
    isAttacking = false;

    _attackTimer = TimerComponent(
      period: 1.5,
      removeOnFinish: true,
      onTick: () {
        _canAttack = true;
      },
    );
    add(_attackTimer!);

    print('✅ ${runtimeType} fin de l\'attaque');
  }

  void _moveTowardsPlayer(double dt) {
    if (playerPosition == null) return;

    final directionX = playerPosition!.x - position.x;
    final horizontalDirection = directionX.sign;

    position.x += horizontalDirection * moveSpeed * dt;
  }

  void _updateFacingDirection() {
    if (playerPosition == null) return;

    final directionX = playerPosition!.x - position.x;
    if (directionX.abs() > 5) {
      final newDirection = directionX > 0;
      if (newDirection != isFacingRight) {
        isFacingRight = newDirection;
        flipEnemy();
        print('🔄 ${runtimeType} - Nouvelle direction: ${isFacingRight ? "DROITE" : "GAUCHE"}');
      }
    }
  }

  void flipEnemy() {
    if (isFacingRight) {
      scale = Vector2(1, 1);
    } else {
      scale = Vector2(-1, 1);
    }
  }

  void updatePlayerPosition(Vector2 newPosition) {
    playerPosition = newPosition;
  }

  void takeDamage(double damage) {
    if (!isActive || isAttacking) return;

    health -= damage;
    current = EnemyState.hurt;

    print('💥 ${runtimeType} touché! Dégâts: $damage, PV: $health/$maxHealth');

    if (health <= 0) {
      _die();
    } else {
      Future.delayed(Duration(milliseconds: 500), () {
        if (isActive && health > 0) {
          current = EnemyState.idle;
        }
      });
    }
  }

  void _die() {
    isActive = false;
    current = EnemyState.dying;

    print('💀 ${runtimeType} vaincu!');

    Future.delayed(Duration(milliseconds: 1000), () {
      removeFromParent();
    });
  }

  double get healthPercentage => health / maxHealth;
  bool get isAlive => isActive && health > 0;

  @override
  void onRemove() {
    _attackTimer?.removeFromParent();
    super.onRemove();
  }
}

class HealthBar extends PositionComponent {
  final Enemy enemy;
  final double width = 60.0;
  final double height = 6.0;

  HealthBar({
    required this.enemy,
    required Vector2 position,
  }) : super(position: position);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final backgroundRect = Rect.fromLTWH(-width / 2, -height / 2, width, height);
    canvas.drawRect(
      backgroundRect,
      Paint()..color = Colors.black.withOpacity(0.8),
    );

    final healthWidth = width * enemy.healthPercentage;
    final healthColor = enemy.healthPercentage > 0.5
        ? Colors.green
        : enemy.healthPercentage > 0.25
        ? Colors.orange
        : Colors.red;

    final healthRect = Rect.fromLTWH(-width / 2, -height / 2, healthWidth, height);
    canvas.drawRect(
      healthRect,
      Paint()..color = healthColor,
    );

    final borderRect = Rect.fromLTWH(-width / 2, -height / 2, width, height);
    canvas.drawRect(
      borderRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = Vector2(0, -enemy.size.y - 5);
  }
}